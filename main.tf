terraform {
  backend "http" {
    address        = "https://code.fbi.h-da.de/api/v4/projects/29307/terraform/state/aws_infrastructure_state"
    lock_address   = "https://code.fbi.h-da.de/api/v4/projects/29307/terraform/state/aws_infrastructure_state/lock"
    unlock_address = "https://code.fbi.h-da.de/api/v4/projects/29307/terraform/state/aws_infrastructure_state/lock"
    username       = "gitlab-ci-token"
    lock_method    = "POST"
    unlock_method  = "DELETE"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
    command     = "aws"
  }
}
