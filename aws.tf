terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "My-VPC"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "My-VPC-Pub-Sub"
  }
}

resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "My-VPC-Pvt-Sub"
  }
}

resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "My-VPC-Igw"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tigw.id
  }

   tags = {
    Name = "My-VPC-Pub-Rt"
  }
}

resource "aws_route_table_association" "pubrtasso" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}


resource "aws_eip" "myeip" {
    domain   = "vpc"
}


resource "aws_nat_gateway" "tnat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "My-VPC-Nat"
  }
}

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tnat.id
  }

   tags = {
    Name = "My-VPC-Pub-Rt"
  }
}

resource "aws_route_table_association" "pvtrtasso" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvtrt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "My-VPC-Sec-Allow_All"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = aws_vpc.myvpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  }

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "pub_instance" {
  ami                                             = "ami-0440d3b780d96b29d"
  instance_type                                   = "t2.micro"
  availability_zone                               = "us-east-1a"
  associate_public_ip_address                     = "true"
  vpc_security_group_ids                          = [aws_security_group.allow_all.id]
  subnet_id                                       = aws_subnet.pubsub.id 
  key_name                                        = "gora_linux1"
  
    tags = {
    Name = "HDFCBANK WEBSERVER"
  }
}


resource "aws_instance" "pvt_instance" {
  ami                                             = "ami-0440d3b780d96b29d"
  instance_type                                   = "t2.micro"
  availability_zone                               = "us-east-1b"
  associate_public_ip_address                     = "true"
  vpc_security_group_ids                          = [aws_security_group.allow_all.id]
  subnet_id                                       = aws_subnet.pvtsub.id 
  key_name                                        = "gora_linux1"
  
    tags = {
    Name = "ICICIBANK WEBSERVER"
  }
}
