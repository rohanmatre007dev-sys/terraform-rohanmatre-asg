################################################################################
# Wrapper calls the official upstream module
# Source: terraform-aws-modules/autoscaling/aws
# Docs:   https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws
#
# This wrapper adds:
#   - Auto naming:          rohanmatre-{env}-{region}-asg
#   - Auto tagging:         Environment, Owner, GitHubRepo, ManagedBy
#   - Env-aware monitoring: detailed monitoring auto-enabled in prod
#   - Env-aware refresh:    instance refresh auto-configured in prod
#   - Safe defaults:        t3.micro, min=1, max=3, desired=1, IMDSv2 enforced
################################################################################

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = ">= 6.29"

  ##############################################################################
  # General
  ##############################################################################
  context         = var.context
  create          = var.create
  name            = local.name
  tags            = local.tags
  use_name_prefix = var.use_name_prefix

  ##############################################################################
  # Autoscaling Group Core
  # EXAM: min_size = always running, max_size = upper limit
  # EXAM: desired_capacity = current target (between min and max)
  # EXAM: health_check_type = EC2 (instance status) or ELB (load balancer)
  # EXAM: ELB health check more accurate — use when behind load balancer
  ##############################################################################
  availability_zone_distribution   = var.availability_zone_distribution
  availability_zones               = var.availability_zones
  capacity_rebalance               = var.capacity_rebalance
  default_cooldown                 = var.default_cooldown
  default_instance_warmup          = var.default_instance_warmup
  desired_capacity                 = var.desired_capacity
  desired_capacity_type            = var.desired_capacity_type
  force_delete                     = var.force_delete
  force_delete_warm_pool           = var.force_delete_warm_pool
  health_check_grace_period        = local.health_check_grace_period
  health_check_type                = var.health_check_type
  ignore_desired_capacity_changes  = var.ignore_desired_capacity_changes
  ignore_failed_scaling_activities = var.ignore_failed_scaling_activities
  instance_maintenance_policy      = var.instance_maintenance_policy
  max_instance_lifetime            = var.max_instance_lifetime
  max_size                         = var.max_size
  min_elb_capacity                 = var.min_elb_capacity
  min_size                         = var.min_size
  protect_from_scale_in            = var.protect_from_scale_in
  service_linked_role_arn          = var.service_linked_role_arn
  suspended_processes              = var.suspended_processes
  termination_policies             = var.termination_policies
  timeouts                         = var.timeouts
  vpc_zone_identifier              = var.vpc_zone_identifier
  wait_for_capacity_timeout        = var.wait_for_capacity_timeout
  wait_for_elb_capacity            = var.wait_for_elb_capacity

  ##############################################################################
  # ASG Tags
  ##############################################################################
  autoscaling_group_tags                         = var.autoscaling_group_tags
  autoscaling_group_tags_not_propagate_at_launch = var.autoscaling_group_tags_not_propagate_at_launch

  ##############################################################################
  # Metrics + Monitoring
  # EXAM: Enable ASG metrics for CloudWatch dashboards
  # EXAM: GroupDesiredCapacity, GroupInServiceInstances most commonly used
  ##############################################################################
  enabled_metrics     = var.enabled_metrics
  metrics_granularity = var.metrics_granularity

  ##############################################################################
  # Launch Template
  # EXAM: Launch Template = preferred over Launch Configuration (deprecated)
  # EXAM: Supports versioning — $Latest, $Default, or specific version number
  ##############################################################################
  create_launch_template          = var.create_launch_template
  default_version                 = var.default_version
  launch_template_description     = var.launch_template_description
  launch_template_id              = var.launch_template_id
  launch_template_name            = local.launch_template_name
  launch_template_tags            = var.launch_template_tags
  launch_template_use_name_prefix = var.launch_template_use_name_prefix
  launch_template_version         = var.launch_template_version
  update_default_version          = var.update_default_version

  ##############################################################################
  # Instance Configuration
  # EXAM: image_id = AMI — region-specific, must match region
  # EXAM: instance_type cannot be used with instance_requirements
  ##############################################################################
  disable_api_stop                     = var.disable_api_stop
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  enable_monitoring                    = local.enable_monitoring
  image_id                             = var.image_id
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_name                        = var.instance_name
  instance_requirements                = var.instance_requirements
  instance_type                        = var.instance_type
  kernel_id                            = var.kernel_id
  key_name                             = var.key_name
  ram_disk_id                          = var.ram_disk_id
  user_data                            = var.user_data

  ##############################################################################
  # Security Groups
  ##############################################################################
  security_groups = var.security_groups

  ##############################################################################
  # Block Device Mappings
  # EXAM: Always encrypt volumes in prod
  # EXAM: delete_on_termination=true removes volumes when instance terminates
  ##############################################################################
  block_device_mappings = var.block_device_mappings

  ##############################################################################
  # Network Interfaces
  ##############################################################################
  network_interfaces = var.network_interfaces

  ##############################################################################
  # Placement
  ##############################################################################
  placement       = var.placement
  placement_group = var.placement_group

  ##############################################################################
  # CPU + Credit Options
  # EXAM: T-type credits — standard (throttles when exhausted) vs unlimited
  ##############################################################################
  cpu_options          = var.cpu_options
  credit_specification = var.credit_specification

  ##############################################################################
  # Metadata Options
  # EXAM: IMDSv2 = http_tokens=required — secure, prevents SSRF attacks
  # EXAM: http_put_response_hop_limit=1 — prevents metadata leakage in containers
  ##############################################################################
  metadata_options = var.metadata_options

  ##############################################################################
  # Capacity Reservation
  ##############################################################################
  capacity_reservation_specification = var.capacity_reservation_specification

  ##############################################################################
  # Spot + Mixed Instances
  # EXAM: use_mixed_instances_policy = combine on-demand + spot for savings
  # EXAM: on_demand_base_capacity = minimum on-demand instances (never spot)
  # EXAM: on_demand_percentage_above_base_capacity = % of additional capacity on-demand
  ##############################################################################
  instance_market_options    = var.instance_market_options
  mixed_instances_policy     = var.mixed_instances_policy
  use_mixed_instances_policy = var.use_mixed_instances_policy

  ##############################################################################
  # Instance Refresh
  # Auto-configured in prod via locals (Rolling, 50% min healthy)
  # EXAM: Instance refresh = zero-downtime rolling replacement of instances
  # EXAM: min_healthy_percentage = never go below this during refresh
  ##############################################################################
  instance_refresh = local.instance_refresh

  ##############################################################################
  # Lifecycle Hooks
  # EXAM: autoscaling:EC2_INSTANCE_LAUNCHING = hook at instance start
  # EXAM: autoscaling:EC2_INSTANCE_TERMINATING = hook at instance stop
  # EXAM: heartbeat_timeout = seconds ASG waits before proceeding
  ##############################################################################
  initial_lifecycle_hooks = var.initial_lifecycle_hooks

  ##############################################################################
  # Warm Pool
  # EXAM: Warm pool = pre-initialized instances ready to scale quickly
  # EXAM: Reduces latency of scale-out events
  ##############################################################################
  warm_pool = var.warm_pool

  ##############################################################################
  # Scaling Policies
  # EXAM: Target Tracking = simplest, maintain metric at target (CPU 60%)
  # EXAM: Step Scaling = different adjustments for different alarm thresholds
  # EXAM: Predictive Scaling = ML-based, good for cyclic traffic patterns
  ##############################################################################
  scaling_policies = var.scaling_policies

  ##############################################################################
  # Schedules
  # EXAM: Scheduled scaling = scale at specific times (business hours pattern)
  ##############################################################################
  schedules = var.schedules

  ##############################################################################
  # Traffic Source (ALB Target Group)
  # EXAM: ALB routes traffic to ASG instances via target groups
  # EXAM: health_check_type=ELB when ASG is behind ALB
  ##############################################################################
  traffic_source_attachments = var.traffic_source_attachments

  ##############################################################################
  # Tag Specifications
  ##############################################################################
  tag_specifications = var.tag_specifications

  ##############################################################################
  # IAM Instance Profile
  # EXAM: Instances need IAM role to call AWS APIs (S3, SSM, DynamoDB etc.)
  # EXAM: Never hardcode AWS credentials on instances — use instance profiles
  ##############################################################################
  create_iam_instance_profile   = var.create_iam_instance_profile
  iam_instance_profile_arn      = var.iam_instance_profile_arn
  iam_instance_profile_name     = var.iam_instance_profile_name
  iam_role_description          = var.iam_role_description
  iam_role_name                 = local.iam_role_name
  iam_role_path                 = var.iam_role_path
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_policies             = var.iam_role_policies
  iam_role_tags                 = var.iam_role_tags
  iam_role_use_name_prefix      = var.iam_role_use_name_prefix

  ##############################################################################
  # Advanced Options
  ##############################################################################
  enclave_options             = var.enclave_options
  hibernation_options         = var.hibernation_options
  license_specifications      = var.license_specifications
  maintenance_options         = var.maintenance_options
  network_performance_options = var.network_performance_options
  private_dns_name_options    = var.private_dns_name_options
}
