/* ECS call to module */
module "us-east-1" {
  source                 = "./modules/ecs"
  ecs_cluster_name       = var.ecs_cluster_name
  ecs_capacity_providers = var.ecs_capacity_providers
  assign_public_ip       = var.assign_public_ip
  use_canary             = true
  canary_percentage      = 15

  providers = {
    aws = aws
  }
}

module "eu-west-1" {
  source                 = "./modules/ecs"
  ecs_cluster_name       = var.ecs_cluster_name
  ecs_capacity_providers = var.ecs_capacity_providers
  assign_public_ip       = var.assign_public_ip
  use_canary             = false
  canary_percentage      = 0

  providers = {
    aws = aws.eu-west-1
  }
}
