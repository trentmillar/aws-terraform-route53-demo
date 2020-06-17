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

resource aws_security_group b {
  provider = aws.b

  vpc_id = aws_vpc.b.id

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
