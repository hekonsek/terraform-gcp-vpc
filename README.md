# Terraform module for GCP VPC

This is Terraform module for simple VPC setup for GPC. It is primarily intended to be used with GKE clusters with VPC+GKE cluster per environment setup.

The main features of this VPC are:
- Ready to be used with VPC-Native GKE
- Avoids Default VPC's CIDR conflicts with VPC peered networks
- Uses NAT gateway for Internet access instead of Default VPC's Default Internet Gateway (so you don't have assign external IP for workload to access Internet)
- Comes with a single subnet
- Comes with secondary IP ranges for pods and services