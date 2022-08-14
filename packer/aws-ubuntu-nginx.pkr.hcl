variable "ami_name" {
  type    = string
}

variable "aws_region" {
  type    = string
}


locals {
    app_name = "webserver"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "PACKER-DEMO-${local.app_name}-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "${var.aws_region}"
  source_ami_filter {
    filters = {
      name                = "${var.ami_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username  = "ubuntu"
  tags = {
    Env  = "DEMO"
    Name = "PACKER-DEMO-${local.app_name}-{{timestamp}}"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
      playbook_file = "ansible/install_nginx.yml"
  }

  post-processor "shell-local" {
    inline = ["echo foo"]
  }
}