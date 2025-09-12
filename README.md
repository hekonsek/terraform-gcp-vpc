# Terraform module for GCP VPC

This is Terraform module for simple VPC setup for GPC. It is primarily intended to be used with GKE clusters with VPC+GKE cluster per environment setup.

The main features of this VPC are:
- Ready to be used with VPC-Native GKE
- Avoids Default VPC's CIDR conflicts with VPC peered networks
- Uses NAT gateway for Internet access instead of Default VPC's Default Internet Gateway (so you don't have assign external IP for workload to access Internet)
- Comes with a single subnet
- Comes with secondary IP ranges for pods and services

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.nat_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Primary subnet CIDR (regional subnet for the VPC) | `string` | `"10.64.0.0/20"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the custom VPC | `string` | `"custom-vpc"` | no |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | CIDR for the Pods secondary IP range on the primary subnet | `string` | `"10.80.0.0/14"` | no |
| <a name="input_pods_ip_range_name"></a> [pods\_ip\_range\_name](#input\_pods\_ip\_range\_name) | Name for the Pods secondary IP range on each subnetwork. | `string` | `"pods"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID to host the VPC | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region, e.g. us-central1 | `string` | n/a | yes |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | CIDR for the Services secondary IP range on the primary subnet | `string` | `"10.96.0.0/20"` | no |
| <a name="input_services_ip_range_name"></a> [services\_ip\_range\_name](#input\_services\_ip\_range\_name) | Name for the Services secondary IP range on each subnetwork. | `string` | `"services"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the primary regional subnet | `string` | `"subnet"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pods_ip_range_name"></a> [pods\_ip\_range\_name](#output\_pods\_ip\_range\_name) | Range name used for GKE Pods secondary ranges on each subnetwork. |
| <a name="output_services_ip_range_name"></a> [services\_ip\_range\_name](#output\_services\_ip\_range\_name) | Range name used for GKE Services secondary ranges on each subnetwork. |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | Name of the VPC |
| <a name="output_vpc_subnet_cidr"></a> [vpc\_subnet\_cidr](#output\_vpc\_subnet\_cidr) | Primary subnet CIDR range |
| <a name="output_vpc_subnet_name"></a> [vpc\_subnet\_name](#output\_vpc\_subnet\_name) | Name of the primary regional subnet |
| <a name="output_vpc_subnet_pods_cidr"></a> [vpc\_subnet\_pods\_cidr](#output\_vpc\_subnet\_pods\_cidr) | CIDR for the Pods secondary IP range on the primary subnet |
| <a name="output_vpc_subnet_region"></a> [vpc\_subnet\_region](#output\_vpc\_subnet\_region) | Region of the primary subnet |
| <a name="output_vpc_subnet_services_cidr"></a> [vpc\_subnet\_services\_cidr](#output\_vpc\_subnet\_services\_cidr) | CIDR for the Services secondary IP range on the primary subnet |
<!-- END_TF_DOCS -->