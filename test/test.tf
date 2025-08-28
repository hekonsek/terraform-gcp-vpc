terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source = "./.." # repo root as module source

  project_id   = var.project_id
  region       = var.region
  network_name = var.network_name
  network_cidr = var.network_cidr
}

output "vpc_name" {
  value = module.vpc.vpc_name
}

output "subnets" {
  value = module.vpc.subnets
}

