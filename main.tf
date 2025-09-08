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
  description = "Primary subnet CIDR (regional subnet for the VPC)"
  type        = string
  default     = "10.64.0.0/20"
}

variable "subnet_name" {
  description = "Name of the primary regional subnet"
  type        = string
  default     = "subnet"
}

variable "pods_cidr" {
  description = "CIDR for the Pods secondary IP range on the primary subnet"
  type        = string
  default     = "10.80.0.0/14"
}

variable "services_cidr" {
  description = "CIDR for the Services secondary IP range on the primary subnet"
  type        = string
  default     = "10.96.0.0/20"
}

variable "pods_ip_range_name" {
  description = "Name for the Pods secondary IP range on each subnetwork."
  type        = string
  default     = "pods"
}

variable "services_ip_range_name" {
  description = "Name for the Services secondary IP range on each subnetwork."
  type        = string
  default     = "services"
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



# Create a custom-mode VPC (no auto subnets)
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create a single regional subnet with secondary ranges for GKE
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.region}-${var.subnet_name}"
  ip_cidr_range = var.network_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }

  secondary_ip_range {
    range_name    = var.pods_ip_range_name
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = var.services_ip_range_name
    ip_cidr_range = var.services_cidr
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


