module "network" {
  source = "./modules/network"
}

module "eks" {
  source      = "./modules/eks"
  subnet_ids  = module.network.subnet_ids
  vpc_id      = module.network.vpc_id
}

module "rds" {
  source      = "./modules/rds"
  subnet_ids  = module.network.subnet_ids
  vpc_id      = module.network.vpc_id
}
