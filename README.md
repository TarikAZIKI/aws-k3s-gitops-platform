# DevOps Platform sur AWS

Plateforme DevOps complète à coût minimal : Terraform → Ansible → k3s → ArgoCD (GitOps),
CI GitHub Actions avec scan Trivy, observabilité Prometheus / Grafana / Loki.

> 🚧 En construction. Étape actuelle : **Terraform (infrastructure AWS)**.

## Architecture (étape Terraform)

```
terraform/
├── bootstrap/        # Une seule fois : bucket S3 du state + budget AWS à 5 $
├── modules/
│   ├── network/      # VPC, sous-réseau public, Internet Gateway (pas de NAT)
│   └── compute/      # Security group, rôle IAM (lecture SSM), EC2 Ubuntu 24.04
└── envs/dev/         # Assemble les modules, state distant dans S3
```

Choix notables :

- **Un seul sous-réseau public, pas de NAT Gateway** : la NAT coûterait ~35 $/mois.
- **State S3 avec verrouillage natif** (`use_lockfile`), sans table DynamoDB.
- **SSH (22) et API Kubernetes (6443) ouverts uniquement à ton IP**, recalculée à chaque `make`.
- **IMDSv2 obligatoire**, disque chiffré, security group par défaut du VPC vidé.
- **Rôle IAM minimal** : l'instance ne lit que les paramètres SSM sous `/devops-platform/*`.

## Prérequis

- Compte AWS avec MFA, CLI connectée via `aws login --region eu-north-1`
- `terraform` ≥ 1.10, `aws` CLI, `make`

## Utilisation

```bash
# Une seule fois
cp terraform/bootstrap/terraform.tfvars.example terraform/bootstrap/terraform.tfvars  # mettre ton e-mail
make bootstrap
make init

# À chaque session
make up      # crée l'infra (~2 min)
make ssh     # connexion à l'instance
make down    # ⚠️ détruit tout en fin de session
```

`make help` liste toutes les commandes.

## Coût

~0,056 $/h quand l'instance tourne (t3.medium + IPv4 + 30 Go gp3), 0 $ une fois détruite
(hors bucket du state : quelques centimes).
