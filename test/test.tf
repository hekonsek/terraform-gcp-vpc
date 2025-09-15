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
  network_name = var.network_name
  network_cidr = var.network_cidr

  # Single regional subnet + two secondary ranges
  pods_cidr              = var.pods_cidr
  services_cidr          = var.services_cidr
  pods_ip_range_name     = var.pods_ip_range_name
  services_ip_range_name = var.services_ip_range_name
}

variable "network_name" {
  default = "test-vpc"
}

output "network_name" {
  value = module.vpc.network_name
}

output "subnetwork_name" {
  value = module.vpc.subnetwork_name
}

output "pods_range_name" {
  value = module.vpc.pods_ip_range_name
}

output "services_range_name" {
  value = module.vpc.services_ip_range_name
}

output "nat_router_name" {
  value = module.vpc.nat_router_name
}

output "nat_name" {
  value = module.vpc.nat_name
}

output "vpc_region" {
  value = module.vpc.vpc_subnet_region
}
