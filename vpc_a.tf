locals {
  a = var.vpcs.a
  a_subnets = {
    a = {
      name = "r53-demo-1a"
      cidr = cidrsubnet(local.a.cidr, 2, 0)
    }
    b = {
      name = "r53-demo-1b"
      cidr = cidrsubnet(local.a.cidr, 2, 1)
    }
  }
}

resource aws_vpc a {
  provider = aws.a

  cidr_block           = local.a.cidr
  enable_dns_hostnames = true
  tags                 = merge(local.tags, map("Name", local.a.name))
}

resource aws_internet_gateway a {
  provider = aws.a

  vpc_id = aws_vpc.a.id
  tags   = merge(local.tags, map("Name", "r53-igw"))
}

resource aws_subnet a_a {
  provider = aws.a

  vpc_id     = aws_vpc.a.id
  cidr_block = local.a_subnets.a.cidr
  tags       = merge(local.tags, map("Name", local.a_subnets.a.name))

}

resource aws_subnet a_b {
  provider = aws.a

  vpc_id     = aws_vpc.a.id
  cidr_block = local.a_subnets.b.cidr
  tags       = merge(local.tags, map("Name", local.a_subnets.b.name))
}

resource aws_route_table a {
  provider = aws.a

  vpc_id = aws_vpc.a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.a.id
  }

  tags = merge(local.tags, map("Name", "r53-demo-rt"))
}

resource aws_security_group a {
  provider = aws.a

  vpc_id = aws_vpc.a.id

  ingress {
    description = "All HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["96.51.130.136/32"]
  }

  tags = merge(local.tags, map("Name", "r53-demo-sg"))
}

data aws_ami a {
  provider = aws.a

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

resource aws_key_pair a {
  provider = aws.a

  key_name   = "r53-key"
  public_key = file(local.key_path)
}

resource aws_instance web01_a {
  provider = aws.a

  ami                    = data.aws_ami.a.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.a.id]
  subnet_id              = aws_subnet.a_a.id
  private_ip             = cidrhost(cidrsubnet(local.a.cidr, 2, 0), 10)
  key_name               = aws_key_pair.a.key_name

  tags = merge(local.tags, map("Name", "web1-east"))
}

resource aws_instance web02_a {
  provider = aws.a

  ami                    = data.aws_ami.a.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.a.id]
  subnet_id              = aws_subnet.a_b.id
  private_ip             = cidrhost(cidrsubnet(local.a.cidr, 2, 1), 20)
  key_name               = aws_key_pair.a.key_name

  tags = merge(local.tags, map("Name", "web2-east"))
}

resource aws_instance db {
  provider = aws.a

  ami                    = data.aws_ami.a.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.a.id]
  subnet_id              = aws_subnet.a_b.id
  private_ip             = cidrhost(cidrsubnet(local.a.cidr, 2, 1), 100)
  key_name               = aws_key_pair.a.key_name

  tags = merge(local.tags, map("Name", "db-east"))
}

