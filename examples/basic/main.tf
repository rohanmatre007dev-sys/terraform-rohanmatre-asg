################################################################################
# Basic Example
# Simple ASG in private subnets — most common real-world pattern
#
# What gets created:
#   - 1 Launch Template (t3.micro, Amazon Linux 2023)
#   - 1 Auto Scaling Group (min=1, max=3, desired=1)
#   - Uses existing VPC + SG from rohanmatre wrappers
#   - EC2 health checks
#   - IMDSv2 enforced
#
# Auto-generated name: rohanmatre-dev-ap-south-1-asg
################################################################################

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "rohanmatre007dev-sys/vpc/rohanmatre"
  version = "1.0.0"

  environment = "dev"
}

module "sg" {
  source  = "rohanmatre007dev-sys/sg/rohanmatre"
  version = "1.0.0"

  environment = "dev"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "asg" {
  source = "../../"

  environment = "dev"

  # Capacity
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  # Network — from vpc wrapper
  vpc_zone_identifier = module.vpc.private_subnet_ids
  security_groups     = [module.sg.security_group_id]

  # Launch template
  image_id      = null # uses latest Amazon Linux 2023 AMI via SSM
  instance_type = "t3.micro"
  key_name      = "my-key-pair"
}
