locals {
  ##############################################################################
  # Naming
  # Pattern: rohanmatre-{environment}-{region}-asg
  # Example: rohanmatre-dev-ap-south-1-asg
  ##############################################################################
  local_name    = "rohanmatre-${var.environment}-${var.region}-asg"
  name          = var.name == null ? local.local_name : var.name
  iam_role_name = var.iam_role_name == null ? local.name : var.iam_role_name

  ##############################################################################
  # Environment-Aware Logic
  # EXAM: Prod ASG should have:
  #   - Higher min_size for availability
  #   - Instance refresh enabled for zero-downtime updates
  #   - Detailed monitoring enabled
  ##############################################################################
  is_prod = var.environment == "prod"

  # Detailed monitoring — always on in prod
  enable_monitoring = local.is_prod ? true : var.enable_monitoring

  # Health check grace period — more time in prod for app to start
  health_check_grace_period = local.is_prod ? 300 : var.health_check_grace_period

  # Instance refresh — enforce rolling updates in prod
  instance_refresh = local.is_prod && var.instance_refresh == null ? {
    strategy = "Rolling"
    triggers = null
    preferences = {
      alarm_specification = {
        alarms = formatlist("%s", [])
      }
      auto_rollback                = null
      checkpoint_delay             = null
      checkpoint_percentages       = null
      instance_warmup              = null
      max_healthy_percentage       = 100
      min_healthy_percentage       = 50
      scale_in_protected_instances = null
      skip_matching                = null
      standby_instances            = null
    }
  } : var.instance_refresh

  ##############################################################################
  # Launch Template Name — auto-derive from ASG name if not provided
  ##############################################################################
  launch_template_name = var.launch_template_name == "" ? "${local.name}-lt" : var.launch_template_name

  ##############################################################################
  # Common Tags
  ##############################################################################
  common_tags = {
    Environment = var.environment
    Owner       = "rohanmatre"
    GitHubRepo  = "terraform-rohanmatre-asg"
    ManagedBy   = "terraform"
  }

  tags = merge(local.common_tags, var.tags, { Name = local.name })
}
