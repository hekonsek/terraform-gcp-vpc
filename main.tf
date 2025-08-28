############################
# variables.tf
############################
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region, e.g. europe-north2"
  type        = string
}

variable "network_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "custom-vpc"
}

variable "network_cidr" {
  description = "Base CIDR for the VPC (must be /20 if you want 16 /24s)"
  type        = string
  default     = "10.64.0.0/20"
}

############################
# main.tf
############################
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}



# Discover all zones in the region
data "google_compute_zones" "available" {
  region = var.region
}

# Basic validation: a /20 contains 16 /24s → ensure zones <= 16
locals {
  zones       = sort(data.google_compute_zones.available.names)
  max_subnets = 16
}

# Create a custom-mode VPC (no auto subnets)
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Map each zone to a unique /24 carved from the /20
# cidrsubnet(<base>, newbits, netnum) → /20 + 4 new bits = /24, 0..15
locals {
  zone_cidrs = {
    for idx, z in local.zones :
    z => cidrsubnet(var.network_cidr, 4, idx)
    if idx < local.max_subnets
  }
}

# Create one regional subnet per zone label (all live in the same region)
resource "google_compute_subnetwork" "subnets" {
  for_each      = local.zone_cidrs
  name          = "${var.region}-${each.key}"
  ip_cidr_range = each.value
  region        = var.region
  network       = google_compute_network.vpc.id

  # Sensible defaults you can tweak
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.1 # 10% sampling; adjust as needed
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ---- Cloud NAT for outbound internet (no external IPs needed) ----

resource "google_compute_router" "nat_router" {
  name    = "${var.region}-nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name   = "${var.region}-nat"
  region = var.region
  router = google_compute_router.nat_router.name

  nat_ip_allocate_option             = "AUTO_ONLY" # Google-managed NAT IPs
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_endpoint_independent_mapping = true

  log_config {
    enable = true
    filter = "ALL" # OPTIONS: ERRORS_ONLY | TRANSLATION_ERRORS | ALL
  }

  # Optional tuning:
  min_ports_per_vm                 = 256 # adjust for high-connection workloads
  udp_idle_timeout_sec             = 30
  tcp_established_idle_timeout_sec = 1200
}

############################
# outputs.tf
############################
output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnets" {
  value = {
    for k, s in google_compute_subnetwork.subnets :
    k => {
      name   = s.name
      cidr   = s.ip_cidr_range
      region = s.region
    }
  }
}
