module "autoscaling-module" {
  source = "./modules/autoscaling-module"
  namespace= var.namespace
  ssh_keypair = var.ssh_keypair

  vpc = module.networking-module.vpc
  sg = module.networking-module.sg
  db_config = module.database-module.db_config
}

module "database-module" {
  source = "./modules/database-module"
  vpc = module.networking-module.vpc
  sg = module.networking-module.sg
  namespace = var.namespace
  }

module "networking-module" {
  source = "./modules/networking-module"
  namespace = var.namespace
}



