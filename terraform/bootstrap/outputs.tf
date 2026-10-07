output "state_bucket" {
  description = "Bucket S3 qui stocke le state Terraform."
  value       = aws_s3_bucket.tfstate.bucket
}

output "backend_config" {
  description = "Contenu du fichier backend.hcl des environnements."
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.tfstate.bucket}"
    region       = "${var.region}"
    encrypt      = true
    use_lockfile = true
  EOT
}
