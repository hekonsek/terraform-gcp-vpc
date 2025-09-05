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

  # Create secondary ranges for every subnetwork (derived from base ranges)
  pods_base_cidr         = var.pods_base_cidr
  services_base_cidr     = var.services_base_cidr
  pods_ip_range_name     = var.pods_ip_range_name
  services_ip_range_name = var.services_ip_range_name
}

output "vpc_name" {
  value = module.vpc.vpc_name
}

output "subnets" {
  value = module.vpc.subnets
}

output "pods_range_name" {
  value = module.vpc.pods_ip_range_name
}

output "services_range_name" {
  value = module.vpc.services_ip_range_name
}
