# Example: Using as module

This example shows how to consume the VPC module from GitHub using a pinned release tag.

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.33.0"
    }
  }
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}

module "vpc" {
  source = "git::https://github.com/hekonsek/terraform-gcp-vpc.git?ref=v1.0.0"

  project_id   = "my-gcp-project"
  region       = "us-central1"
  network_name = "prod"

  network_cidr  = "10.64.0.0/20"
  pods_cidr     = "10.80.0.0/14"
  services_cidr = "10.96.0.0/20"

  nat_log_filter = "ERRORS_ONLY"
}
```

Use a pinned `ref` value, such as a release tag, instead of tracking a moving branch.
