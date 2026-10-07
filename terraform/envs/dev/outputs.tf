output "instance_id" {
  value = module.compute.instance_id
}

output "public_ip" {
  value = module.compute.public_ip
}

output "ssh_command" {
  value = "ssh -i ${trimsuffix(pathexpand(var.ssh_public_key_path), ".pub")} ubuntu@${module.compute.public_ip}"
}

output "app_base_url" {
  description = "Free wildcard domain pointing to the instance (sslip.io)."
  value       = "${replace(module.compute.public_ip, ".", "-")}.sslip.io"
}
