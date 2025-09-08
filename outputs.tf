output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_subnet_name" {
  description = "Name of the primary regional subnet"
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
