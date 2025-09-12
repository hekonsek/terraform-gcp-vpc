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
}

module "vpc" {
  source = "./.." # repo root as module source

  project_id   = var.project_id
  network_name = "test-vpc"
  network_cidr = var.network_cidr

  # Single regional subnet + two secondary ranges
  pods_cidr              = var.pods_cidr
  services_cidr          = var.services_cidr
  pods_ip_range_name     = var.pods_ip_range_name
  services_ip_range_name = var.services_ip_range_name
}

output "vpc_name" {
  value = module.vpc.vpc_name
}

output "subnet" {
  value = module.vpc.vpc_subnet_name
}

output "pods_range_name" {
  value = module.vpc.pods_ip_range_name
}

output "services_range_name" {
  value = module.vpc.services_ip_range_name
}
