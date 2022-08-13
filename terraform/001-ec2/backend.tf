terraform {
  backend "s3" {
    bucket         = "demo-toolchain-remotestate"
    dynamodb_table = "terraform-state-lock"
    key            = "compute/terraform.tfstate"
    profile        = "demotoolchain"
    region         = "us-west-2"
  }
}