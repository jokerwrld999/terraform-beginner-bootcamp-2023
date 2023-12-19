terraform {
  cloud {
    organization = "jokerwrld"

    workspaces {
      name = "terraform-bootcamp"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.20.0"
    }
  }

  required_version = ">= 1.5.0"
}

# AWS provider block

provider "aws" {
  region     = var.region
  # access_key = var.AWS_ACCESS_KEY_ID
  # secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "cloudflare" {
  api_token = var.cloudflare_api_key
}