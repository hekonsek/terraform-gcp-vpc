SHELL := /bin/bash

.PHONY: test
test: ## Run Terratest (requires Go, Terraform, and GCP project env)
	@echo "Running Terratest..."
	@cd test && go test -v -timeout 45m

.PHONY: test-plan
test-plan: ## Run Terraform plan in test harness (no apply)
	@cd test && terraform init -backend=false && terraform plan -var "project_id=${GOOGLE_CLOUD_PROJECT}" || true

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .+' $(MAKEFILE_LIST) | awk 'BEGIN {FS=":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

