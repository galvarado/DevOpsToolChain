terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

variable "vm_name" {
  type    = string
}

variable "packer_ami_name" {
  type    = string
}

variable "aws_region" {
  type    = string
}

variable "instance_type" {
  type    = string
}


provider "aws" {
  region = var.aws_region
}

data "aws_ami" "webserver" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["${var.packer_ami_name}*"]
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


data "aws_vpc" "default" {
  default  = true
}

resource "aws_security_group" "web" {
  name        = "web"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("../ssh-keys/id_rsa.pub")
}

resource "aws_instance" "webserver" {
  ami           = data.aws_ami.webserver.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.web.name]
  key_name         = "deployer-key"

  tags = {
    Env  = "DEMO"
    Name = "${var.vm_name}-by-terraform"
  }
}

