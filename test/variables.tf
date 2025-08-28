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

