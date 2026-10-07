locals {
  name = "${var.project_name}-dev"
}

module "network" {
  source = "../../modules/network"

  name = local.name
}

module "compute" {
  source = "../../modules/compute"

  name               = local.name
  vpc_id             = module.network.vpc_id
  subnet_id          = module.network.public_subnet_id
  instance_type      = var.instance_type
  admin_cidr         = var.admin_cidr
  ssh_public_key     = var.ssh_public_key != null ? var.ssh_public_key : file(pathexpand(var.ssh_public_key_path))
  ssm_parameter_path = "/${var.project_name}"
}
