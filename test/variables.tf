variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network_cidr" {
  description = "Primary subnet CIDR for the VPC"
  type        = string
  default     = "10.64.0.0/20"
}

# GKE secondary ranges (single subnet)
variable "pods_cidr" {
  description = "CIDR for Pods secondary range"
  type        = string
  default     = "10.80.0.0/14"
}

variable "services_cidr" {
  description = "CIDR for Services secondary range"
  type        = string
  default     = "10.96.0.0/20"
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
