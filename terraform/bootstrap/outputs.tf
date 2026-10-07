output "state_bucket" {
  description = "S3 bucket that stores the Terraform state."
  value       = aws_s3_bucket.tfstate.bucket
}

output "backend_config" {
  description = "Content of the environments' backend.hcl file."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.tfstate.bucket}"
    region       = "${var.region}"
    encrypt      = true
    use_lockfile = true
  EOT
}

output "github_plan_role_arn" {
  description = "IAM role assumed by the Terraform workflow through OIDC."
  value       = var.enable_github_oidc ? aws_iam_role.github_plan[0].arn : null
}
