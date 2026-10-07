# Point d'entrée unique du projet. `make help` liste les commandes.

SHELL      := /bin/bash
TF_BOOT    := terraform -chdir=terraform/bootstrap
TF_DEV     := terraform -chdir=terraform/envs/dev
SSH_KEY    := $(HOME)/.ssh/devops-platform

# Ton IP publique, recalculée à chaque commande : le security group suit tes changements de réseau.
MY_IP       = $(shell curl -fsS https://checkip.amazonaws.com)
export TF_VAR_admin_cidr = $(MY_IP)/32

.PHONY: help keygen bootstrap init fmt validate plan up down ssh

help: ## Affiche cette aide
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

keygen: ## Crée la clé SSH du projet si elle n'existe pas
	@test -f $(SSH_KEY) || ssh-keygen -t ed25519 -f $(SSH_KEY) -N "" -C devops-platform

bootstrap: ## (Une seule fois) Crée le bucket du state et le budget AWS
	$(TF_BOOT) init
	$(TF_BOOT) apply
	$(TF_BOOT) output -raw backend_config > terraform/envs/dev/backend.hcl

init: ## Initialise l'environnement dev sur le backend S3
	$(TF_DEV) init -backend-config=backend.hcl

fmt: ## Formate et vérifie tout le code Terraform
	terraform fmt -recursive terraform

validate: fmt ## Valide la configuration dev
	$(TF_DEV) validate

plan: keygen ## Affiche ce que `make up` va changer
	$(TF_DEV) plan

up: keygen ## Crée l'infrastructure AWS
	$(TF_DEV) apply

down: ## Détruit toute l'infrastructure (à faire en fin de session !)
	$(TF_DEV) destroy

ssh: ## Se connecte en SSH à l'instance
	ssh -i $(SSH_KEY) ubuntu@$$($(TF_DEV) output -raw public_ip)
