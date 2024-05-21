terraform {
  required_version = ">= 0.13.1"

required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73"
    }
  }

backend "s3" {
    bucket         = "linuxeroscostate"
    key            = "lab-terraform/produccion/terraform-tfstate"
    region         = "us-east-1"
    dynamodb_table = "linuxerosco-lock-pdn"
    profile        = "pragmacloudops-terra"
  }
 }