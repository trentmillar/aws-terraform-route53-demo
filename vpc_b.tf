locals {
  b = var.vpcs.b
  b_subnets = {
    a = {
      name = "r53-demo-1a"
      cidr = cidrsubnet(local.b.cidr, 2, 0)
    }
    b = {
      name = "r53-demo-1b"
      cidr = cidrsubnet(local.b.cidr, 2, 1)
    }
  }

  b_context = {
    region = data.aws_region.b.name
    web01  = aws_instance.web01_b.public_ip
    web02  = aws_instance.web02_b.public_ip
  }
}

data aws_region b {
  provider = aws.b
}

resource aws_vpc b {
  provider = aws.b

  cidr_block           = local.b.cidr
  enable_dns_hostnames = true
  tags                 = merge(local.tags, map("Name", local.b.name))
}

resource aws_internet_gateway b {
  provider = aws.b

  vpc_id = aws_vpc.b.id
  tags   = merge(local.tags, map("Name", "r53-igw"))
}

resource aws_subnet b_a {
  provider = aws.b

  vpc_id     = aws_vpc.b.id
  cidr_block = local.b_subnets.a.cidr
  tags       = merge(local.tags, map("Name", local.b_subnets.a.name))

}

resource aws_subnet b_b {
  provider = aws.b

  vpc_id     = aws_vpc.b.id
  cidr_block = local.b_subnets.b.cidr
  tags       = merge(local.tags, map("Name", local.b_subnets.b.name))
}

resource aws_route_table b {
  provider = aws.b

  vpc_id = aws_vpc.b.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.b.id
  }

  tags = merge(local.tags, map("Name", "r53-demo-rt"))
}

resource aws_route_table_association b_a {
  provider = aws.b

  subnet_id      = aws_subnet.b_a.id
  route_table_id = aws_route_table.b.id
}

resource aws_route_table_association b_b {
  provider = aws.b

  subnet_id      = aws_subnet.b_b.id
  route_table_id = aws_route_table.b.id
}

resource aws_security_group b {
  provider = aws.b

  vpc_id = aws_vpc.b.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "96.51.130.136/32"
    ]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "96.51.130.136/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, map("Name", "r53-demo-sg"))
}

data aws_ami b {
  provider = aws.b

  most_recent = true
  name_regex  = "^aws-elasticbeanstalk-amzn-.+-ecs-hvm-.+$"
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["aws-elasticbeanstalk-amzn-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource aws_key_pair b {
  provider = aws.b

  key_name   = "r53-key"
  public_key = file(local.key_path)
}

resource aws_instance web01_b {
  provider = aws.b

  ami                         = data.aws_ami.b.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.b.id]
  subnet_id                   = aws_subnet.b_a.id
  private_ip                  = cidrhost(cidrsubnet(local.b.cidr, 2, 0), 10)
  key_name                    = aws_key_pair.b.key_name
  associate_public_ip_address = true

  tags = merge(local.tags, map("Name", "web1-west"))
}

resource aws_instance web02_b {
  provider = aws.b

  ami                         = data.aws_ami.b.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.b.id]
  subnet_id                   = aws_subnet.b_b.id
  private_ip                  = cidrhost(cidrsubnet(local.b.cidr, 2, 1), 20)
  key_name                    = aws_key_pair.b.key_name
  associate_public_ip_address = true

  tags = merge(local.tags, map("Name", "web2-west"))
}
