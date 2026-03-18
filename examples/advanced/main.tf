################################################################################
# Advanced Example
# Production-grade ASG with scaling policies, IAM, instance refresh
#
# What gets created:
#   - Launch Template (encrypted EBS, IMDSv2, IAM profile)
#   - ASG (min=2, max=10, across 3 AZs for HA)
#   - Target Tracking scaling policy (CPU at 60%)
#   - Rolling instance refresh (auto in prod via locals)
#   - IAM role with SSM access
#   - ELB health check (when attached to ALB)
#   - Scheduled scale-down at night
#
# Prod auto-sets: instance_refresh=Rolling, detailed monitoring, health grace=300s
################################################################################

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source  = "rohanmatre007dev-sys/vpc/rohanmatre"
  version = "1.0.0"

  environment     = "prod"
  cidr            = "10.10.0.0/16"
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

module "sg" {
  source  = "rohanmatre007dev-sys/sg/rohanmatre"
  version = "1.0.0"

  environment = "prod"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "asg" {
  source = "../../"

  name        = "rohanmatre-prod-web-asg"
  environment = "prod"

  # Capacity — min=2 for HA across AZs
  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  # Network — spread across all 3 private subnets
  vpc_zone_identifier = module.vpc.private_subnet_ids
  security_groups     = [module.sg.security_group_id]

  # Health check — ELB (more accurate when behind ALB)
  health_check_type = "ELB"

  # Launch template
  instance_type = "t3.small"
  key_name      = "prod-key-pair"

  # IAM — SSM access for session manager (no bastion needed)
  create_iam_instance_profile = true
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Encrypted root volume for prod
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        encrypted             = true
        delete_on_termination = true
      }
    }
  ]

  # Scaling policies — Target Tracking CPU at 60%
  scaling_policies = {
    cpu_tracking = {
      policy_type = "TargetTrackingScaling"
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 60.0
      }
    }
  }

  # Scheduled scaling — scale down at night, scale up in morning
  schedules = {
    scale_down_night = {
      min_size         = 1
      max_size         = 10
      desired_capacity = 1
      recurrence       = "0 20 * * *" # 8pm UTC daily
      time_zone        = "Asia/Kolkata"
    }
    scale_up_morning = {
      min_size         = 2
      max_size         = 10
      desired_capacity = 2
      recurrence       = "0 8 * * MON-FRI" # 8am UTC weekdays
      time_zone        = "Asia/Kolkata"
    }
  }

  # Enabled metrics for CloudWatch dashboards
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  # Prod auto-sets: instance_refresh=Rolling 50% min healthy, monitoring=true
  tags = {
    Project = "rohanmatre-platform"
    Role    = "web-tier"
  }
}
