############################
# outputs.tf
############################

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnets" {
  value = {
    (var.subnet_name) = {
      name          = google_compute_subnetwork.subnet.name
      cidr          = google_compute_subnetwork.subnet.ip_cidr_range
      region        = google_compute_subnetwork.subnet.region
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }
}

output "pods_ip_range_name" {
  description = "Range name used for GKE Pods secondary ranges on each subnetwork."
  value       = var.pods_ip_range_name
}

output "services_ip_range_name" {
  description = "Range name used for GKE Services secondary ranges on each subnetwork."
  value       = var.services_ip_range_name
}

