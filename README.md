# Terraform module for GCP VPC

This is Terraform module for simple VPC setup for GPC.

The main reasons to use such VPC instead of GCP default VPC are:
- Avoiding CIDR conflicts with VPC peered networks
- Using NAT gateway for Internet access instead of Default Internet Gateway (so you don't have assign external IP for workload to access Internet)