# Application secrets live in SSM Parameter Store (standard tier: free), never in
# Git. The instance role can read /<project>/*, and External Secrets Operator
# copies them into Kubernetes Secrets. A new password is generated every session.

resource "random_password" "grafana_admin" {
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "grafana_admin_password" {
  name        = "/${var.project_name}/grafana/admin-password"
  description = "Grafana admin password, synced into the cluster by External Secrets."
  type        = "SecureString"
  value       = random_password.grafana_admin.result
}
