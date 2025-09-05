variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region, e.g. europe-north2"
  type        = string
  default     = "europe-north2"
}

variable "network_name" {
  description = "Name of the test VPC"
  type        = string
  default     = "test-vpc"
}

variable "network_cidr" {
  description = "Base CIDR for the VPC"
  type        = string
  default     = "10.64.0.0/20"
}

# GKE secondary ranges base CIDRs (will be subdivided per subnet)
variable "pods_base_cidr" {
  description = "Base CIDR to derive Pods secondary ranges for all subnets"
  type        = string
  default     = "10.80.0.0/14"
}

variable "services_base_cidr" {
  description = "Base CIDR to derive Services secondary ranges for all subnets"
  type        = string
  default     = "10.96.0.0/16"
}

variable "pods_ip_range_name" {
  description = "Name for Pods range"
  type        = string
  default     = "pods"
}

variable "services_ip_range_name" {
  description = "Name for Services range"
  type        = string
  default     = "services"
}
