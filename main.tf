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

