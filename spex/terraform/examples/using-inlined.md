# Example: Using inlined resources

This example shows how to copy the module's variables, resources, and outputs directly into a root Terraform module instead of consuming it with a `module` block.

## Root module

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.33.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
```

## Variables

```hcl
variable "project_id" {
  description = "GCP project ID to host the VPC"
  type        = string
}

variable "region" {
  description = "GCP region, e.g. us-central1"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "Name of the custom VPC"
  type        = string
  default     = "vpc"
}

variable "network_cidr" {
  description = "Primary subnet CIDR (regional subnet for the VPC)"
  type        = string
  default     = "10.64.0.0/20"
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
  default     = ""
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

variable "nat_log_filter" {
  description = "Cloud NAT logging filter. Valid values are ERRORS_ONLY, TRANSLATION_ERRORS, and ALL."
  type        = string
  default     = "ERRORS_ONLY"

  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATION_ERRORS", "ALL"], var.nat_log_filter)
    error_message = "nat_log_filter must be one of ERRORS_ONLY, TRANSLATION_ERRORS, or ALL."
  }
}
```

## Resources

```hcl
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Create a single regional subnet with secondary ranges for GKE
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnetwork_name != "" ? var.subnetwork_name : "${var.network_name}-subnet"
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

# Cloud NAT for outbound internet

resource "google_compute_router" "nat_router" {
  name    = "${var.network_name}-${var.region}-nat-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name   = "${var.network_name}-${var.region}-nat"
  region = var.region
  router = google_compute_router.nat_router.name

  nat_ip_allocate_option             = "AUTO_ONLY" # Google-managed NAT IPs
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_endpoint_independent_mapping = true

  log_config {
    enable = true
    filter = var.nat_log_filter
  }

  # Optional tuning:
  min_ports_per_vm                 = 256 # adjust for high-connection workloads
  udp_idle_timeout_sec             = 30
  tcp_established_idle_timeout_sec = 1200
}
```

## Outputs

```hcl
output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "subnetwork_name" {
  description = "Name of the primary subnetwork"
  value       = google_compute_subnetwork.subnet.name
}

output "vpc_subnet_cidr" {
  description = "Primary subnet CIDR range"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "vpc_subnet_region" {
  description = "Region of the primary subnet"
  value       = google_compute_subnetwork.subnet.region
}

output "vpc_subnet_pods_cidr" {
  description = "CIDR for the Pods secondary IP range on the primary subnet"
  value       = var.pods_cidr
}

output "vpc_subnet_services_cidr" {
  description = "CIDR for the Services secondary IP range on the primary subnet"
  value       = var.services_cidr
}

output "pods_ip_range_name" {
  description = "Range name used for GKE Pods secondary ranges on each subnetwork."
  value       = var.pods_ip_range_name
}

output "services_ip_range_name" {
  description = "Range name used for GKE Services secondary ranges on each subnetwork."
  value       = var.services_ip_range_name
}

output "nat_router_name" {
  description = "Name of the Cloud Router used for NAT"
  value       = google_compute_router.nat_router.name
}

output "nat_name" {
  description = "Name of the Cloud NAT"
  value       = google_compute_router_nat.nat.name
}
```

## Example values

```hcl
project_id = "my-gcp-project"

region       = "us-central1"
network_name = "prod"

network_cidr  = "10.64.0.0/20"
pods_cidr     = "10.80.0.0/14"
services_cidr = "10.96.0.0/20"

nat_log_filter = "ERRORS_ONLY"
```
