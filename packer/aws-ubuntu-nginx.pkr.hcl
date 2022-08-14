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

  provisioner "shell" {
    script = "scripts/setup.sh"
    # Run script after cloud-init finishes, otherwise you run into race conditions
    execute_command = "/usr/bin/cloud-init status --wait && sudo -E -S sh '{{ .Path }}'"
  }

}