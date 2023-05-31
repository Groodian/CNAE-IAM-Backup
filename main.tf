terraform {
  /*
  backend "http" {
    address        = "https://code.fbi.h-da.de/api/v4/projects/29127/terraform/state/aws_infrastructure_state"
    lock_address   = "https://code.fbi.h-da.de/api/v4/projects/29127/terraform/state/aws_infrastructure_state/lock"
    unlock_address = "https://code.fbi.h-da.de/api/v4/projects/29127/terraform/state/aws_infrastructure_state/lock"
    username       = "gitlab-ci-token"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }*/

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
}
