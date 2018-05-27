provider "aws" {
  region = "us-west-1"
}

terraform {
  backend "s3" {
    bucket = "adborden-terraform"
    key    = "jenkins/terraform.tfstate"
    region = "us-west-1"
  }
}
