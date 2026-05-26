# Terraform module for GCP VPC

This is Terraform module for simple VPC setup for GCP. It is primarily intended to be used with GKE clusters with VPC+GKE cluster per environment setup.

The main features of this VPC are:
- Ready to be used with VPC-Native GKE
- Avoids Default VPC's CIDR conflicts with VPC peered networks
- Uses Cloud NAT so private GKE nodes and workloads can access the Internet without external IP addresses
- Comes with a single regional subnet (suitable for multi-AZ GKE clusters)
- Comes with secondary IP ranges for pods and services
