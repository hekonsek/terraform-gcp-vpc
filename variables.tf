variable "project_id" {
  description = "GCP project ID to host the VPC"
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

