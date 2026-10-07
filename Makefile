# Single entry point for the project. `make help` lists the commands.

SHELL      := /bin/bash
TF_BOOT    := terraform -chdir=terraform/bootstrap
TF_DEV     := terraform -chdir=terraform/envs/dev
SSH_KEY    := $(HOME)/.ssh/devops-platform

# Your public IP, recomputed on every run: the security group follows your network changes.
MY_IP       = $(shell curl -fsS https://checkip.amazonaws.com)
export TF_VAR_admin_cidr = $(MY_IP)/32

SSH_OPTS   := -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null
KUBECTL    := kubectl --kubeconfig $(HOME)/.kube/devops-platform.yaml

.PHONY: help keygen check-aws bootstrap init fmt validate plan up down ssh inventory configure session app-url argocd-password argocd-ui grafana-password grafana-ui

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

keygen: ## Create the project SSH key if missing
	@test -f $(SSH_KEY) || ssh-keygen -t ed25519 -f $(SSH_KEY) -N "" -C devops-platform

check-aws: ## Check that the AWS CLI session is valid
	@aws sts get-caller-identity --query Arn --output text >/dev/null 2>&1 || { echo "AWS session expired: run  aws login --region eu-north-1"; exit 1; }

bootstrap: ## (Once) Create the state bucket and the AWS budget
	$(TF_BOOT) init
	$(TF_BOOT) apply
	$(TF_BOOT) output -raw backend_config > terraform/envs/dev/backend.hcl

init: ## Initialize the dev environment on the S3 backend
	$(TF_DEV) init -backend-config=backend.hcl

fmt: ## Format all Terraform code
	terraform fmt -recursive terraform

validate: fmt ## Validate the dev configuration
	$(TF_DEV) validate

plan: check-aws keygen ## Show what `make up` will change
	$(TF_DEV) plan

up: check-aws keygen ## Create the AWS infrastructure
	$(TF_DEV) apply

down: check-aws ## Destroy all the infrastructure (run at the end of every session!)
	$(TF_DEV) destroy

ssh: ## SSH into the instance
	ssh $(SSH_OPTS) -i $(SSH_KEY) ubuntu@$$($(TF_DEV) output -raw public_ip)

inventory: ## Generate the Ansible inventory from Terraform outputs
	@printf '[k3s]\nnode ansible_host=%s\n' "$$($(TF_DEV) output -raw public_ip)" > ansible/inventory.ini
	@cat ansible/inventory.ini

configure: inventory ## Configure the server, install k3s and Argo CD (Ansible)
	cd ansible && ansible-galaxy collection install -r requirements.yml
	cd ansible && ansible-playbook site.yml

session: up configure ## Create then configure the infrastructure (up + configure)

app-url: ## Print the public URL of the demo application
	@echo "http://$$($(TF_DEV) output -raw public_ip)/"

argocd-password: ## Print the initial Argo CD admin password
	@$(KUBECTL) -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

argocd-ui: ## Open the Argo CD UI on https://localhost:8080 (not exposed publicly)
	$(KUBECTL) -n argocd port-forward svc/argocd-server 8080:443

grafana-password: ## Print the Grafana admin password (user: admin)
	@$(KUBECTL) -n monitoring get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo

grafana-ui: ## Open Grafana on http://localhost:3000 (not exposed publicly)
	$(KUBECTL) -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
