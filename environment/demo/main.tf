terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket  = "interview-terraform-state-12345"
    key     = "demo-app/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    random = {
      source = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "random_id" "suffix" { byte_length = 4 }
locals { name_prefix = "${var.project}-${random_id.suffix.hex}" }

# ================= VPC =================
module "vpc" {
  source              = "../../modules/vpc"
  name_prefix         = local.name_prefix
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

# ================= ALB =================
module "alb" {
  source            = "../../modules/alb"
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
}

# ================= ECS =================
module "ecs" {
  source               = "../../modules/ecs"
  name_prefix          = local.name_prefix
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_target_group_arn = module.alb.target_group_arn
  alb_sg_id            = module.alb.alb_sg_id

  container_image = var.container_image
  container_port  = var.container_port
  desired_count   = var.desired_count
  instance_type   = var.instance_type
}

output "alb_dns_name" { value = module.alb.alb_dns_name }
