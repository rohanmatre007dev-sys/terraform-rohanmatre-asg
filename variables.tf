################################################################################
# General
################################################################################

variable "create" {
  description = "Controls whether ASG and all resources will be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region where ASG will be created"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "name" {
  description = "Name used across all ASG resources. Auto-generated if null."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags merged with common tags"
  type        = map(string)
  default     = {}
}

variable "use_name_prefix" {
  description = "Use name as prefix to create unique name"
  type        = bool
  default     = true
}

variable "context" {
  description = "Reserved context variable"
  type        = string
  default     = null
}

################################################################################
# Autoscaling Group Core
# EXAM: ASG = automatically adjusts EC2 capacity based on demand
# EXAM: min_size = floor, max_size = ceiling, desired_capacity = current target
# EXAM: Health check types — EC2 (default, checks instance status) or ELB (checks target health)
################################################################################

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances. Null = AWS manages it."
  type        = number
  default     = 1
}

variable "desired_capacity_type" {
  description = "Unit for desired_capacity. Valid values: units, vcpu, memory-mib"
  type        = string
  default     = null
}

variable "ignore_desired_capacity_changes" {
  description = "Ignore desired_capacity changes after initial apply (allows external scaling)"
  type        = bool
  default     = false
}

variable "health_check_type" {
  description = "Health check type: EC2 (instance status) or ELB (load balancer health)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Seconds after instance launch before health checks begin"
  type        = number
  default     = 300
}

variable "vpc_zone_identifier" {
  description = "List of subnet IDs. From rohanmatre-vpc-wrapper output (private_subnet_ids)."
  type        = list(string)
  default     = null
}

variable "availability_zones" {
  description = "List of AZs. Use only when NOT using vpc_zone_identifier."
  type        = list(string)
  default     = null
}

variable "availability_zone_distribution" {
  description = "Capacity distribution strategy across AZs"
  type = object({
    capacity_distribution_strategy = optional(string)
  })
  default = null
}

variable "default_cooldown" {
  description = "Seconds between a scaling activity completing and next one starting"
  type        = number
  default     = null
}

variable "default_instance_warmup" {
  description = "Seconds until new instance contributes to CloudWatch metrics"
  type        = number
  default     = null
}

variable "capacity_rebalance" {
  description = "Enable capacity rebalancing for spot instances"
  type        = bool
  default     = null
}

variable "wait_for_capacity_timeout" {
  description = "Max time Terraform waits for ASG capacity. Set to 0 to skip waiting."
  type        = string
  default     = "0"
}

variable "wait_for_elb_capacity" {
  description = "Wait for this many healthy instances in attached load balancers"
  type        = number
  default     = null
}

variable "min_elb_capacity" {
  description = "Minimum healthy instances in ELB on creation"
  type        = number
  default     = null
}

variable "protect_from_scale_in" {
  description = "Prevent ASG from terminating these instances during scale-in"
  type        = bool
  default     = false
}

variable "service_linked_role_arn" {
  description = "ARN of service-linked role for ASG to call AWS services"
  type        = string
  default     = null
}

variable "max_instance_lifetime" {
  description = "Max seconds an instance can be in service (0 or 86400-31536000)"
  type        = number
  default     = null
}

variable "suspended_processes" {
  description = "List of ASG processes to suspend: Launch, Terminate, HealthCheck, etc."
  type        = list(string)
  default     = []
}

variable "termination_policies" {
  description = "Order of policies for instance termination during scale-in"
  type        = list(string)
  default     = []
}

variable "force_delete" {
  description = "Delete ASG without waiting for all instances to terminate"
  type        = bool
  default     = null
}

variable "force_delete_warm_pool" {
  description = "Delete ASG without waiting for warm pool instances to terminate"
  type        = bool
  default     = null
}

variable "ignore_failed_scaling_activities" {
  description = "Ignore failed scaling activities while waiting for capacity"
  type        = bool
  default     = false
}

variable "timeouts" {
  description = "Timeout configuration for ASG delete operation"
  type = object({
    delete = optional(string)
  })
  default = null
}

################################################################################
# ASG Tags
################################################################################

variable "autoscaling_group_tags" {
  description = "Additional tags for the ASG only (not propagated to instances)"
  type        = map(string)
  default     = {}
}

variable "autoscaling_group_tags_not_propagate_at_launch" {
  description = "Tag keys that should NOT propagate to launched EC2 instances"
  type        = list(string)
  default     = []
}

################################################################################
# Metrics + Monitoring
# EXAM: ASG metrics — GroupDesiredCapacity, GroupInServiceInstances etc.
# EXAM: Enable metrics for CloudWatch dashboards and alarms
################################################################################

variable "enabled_metrics" {
  description = "List of ASG metrics to collect for CloudWatch"
  type        = list(string)
  default     = []
}

variable "metrics_granularity" {
  description = "Granularity for ASG metrics. Only valid value is 1Minute."
  type        = string
  default     = null
}

################################################################################
# Launch Template
# EXAM: Launch Template = versioned instance configuration (newer than Launch Config)
# EXAM: Launch Template supports mixed instances policy
################################################################################

variable "create_launch_template" {
  description = "Create a new launch template. Set false to use existing."
  type        = bool
  default     = true
}

variable "launch_template_name" {
  description = "Name of the launch template to create"
  type        = string
  default     = ""
}

variable "launch_template_description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "launch_template_use_name_prefix" {
  description = "Use launch_template_name as prefix"
  type        = bool
  default     = true
}

variable "launch_template_version" {
  description = "Launch template version: number, $Latest, or $Default"
  type        = string
  default     = null
}

variable "launch_template_id" {
  description = "ID of existing launch template (when create_launch_template=false)"
  type        = string
  default     = null
}

variable "launch_template_tags" {
  description = "Additional tags for the launch template"
  type        = map(string)
  default     = {}
}

variable "update_default_version" {
  description = "Update default launch template version on each update"
  type        = bool
  default     = null
}

variable "default_version" {
  description = "Default version of launch template. Conflicts with update_default_version."
  type        = string
  default     = null
}

################################################################################
# Instance Configuration (Launch Template)
# EXAM: image_id = AMI ID — blueprint for instances in ASG
# EXAM: instance_type = size of instances (t3.micro, m5.large etc.)
################################################################################

variable "image_id" {
  description = "AMI ID for instances launched by ASG"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type. Cannot be set with instance_requirements."
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag propagated to launched EC2 instances"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Key pair name for SSH access to launched instances"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64-encoded user data for instance bootstrap"
  type        = string
  default     = null
}

variable "kernel_id" {
  description = "Kernel ID for the launch template"
  type        = string
  default     = null
}

variable "ram_disk_id" {
  description = "RAM disk ID for the launch template"
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "Launch EBS-optimized instances (dedicated EBS bandwidth)"
  type        = bool
  default     = null
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring on launched instances"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Enable termination protection on launched instances"
  type        = bool
  default     = null
}

variable "disable_api_stop" {
  description = "Enable stop protection on launched instances"
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior: stop or terminate"
  type        = string
  default     = null
}

################################################################################
# Security Groups
################################################################################

variable "security_groups" {
  description = "List of security group IDs. From rohanmatre-sg-wrapper output."
  type        = list(string)
  default     = []
}

################################################################################
# Block Device Mappings
# EXAM: EBS volume types — gp3 (default), gp2, io1/io2, st1, sc1
# EXAM: Always encrypt volumes in prod — use encrypted=true
################################################################################

variable "block_device_mappings" {
  description = "Additional EBS volumes to attach to launched instances"
  type = list(object({
    device_name  = optional(string)
    no_device    = optional(string)
    virtual_name = optional(string)
    ebs = optional(object({
      delete_on_termination      = optional(bool)
      encrypted                  = optional(bool)
      iops                       = optional(number)
      kms_key_id                 = optional(string)
      snapshot_id                = optional(string)
      throughput                 = optional(number)
      volume_initialization_rate = optional(number)
      volume_size                = optional(number)
      volume_type                = optional(string)
    }))
  }))
  default = null
}

################################################################################
# Network Interfaces
################################################################################

variable "network_interfaces" {
  description = "Custom network interfaces for instances at boot"
  type = list(object({
    associate_carrier_ip_address = optional(bool)
    associate_public_ip_address  = optional(bool)
    connection_tracking_specification = optional(object({
      tcp_established_timeout = optional(number)
      udp_stream_timeout      = optional(number)
      udp_timeout             = optional(number)
    }))
    delete_on_termination = optional(bool)
    description           = optional(string)
    device_index          = optional(number)
    ena_srd_specification = optional(object({
      ena_srd_enabled = optional(bool)
      ena_srd_udp_specification = optional(object({
        ena_srd_udp_enabled = optional(bool)
      }))
    }))
    interface_type       = optional(string)
    ipv4_address_count   = optional(number)
    ipv4_addresses       = optional(list(string))
    ipv4_prefix_count    = optional(number)
    ipv4_prefixes        = optional(list(string))
    ipv6_address_count   = optional(number)
    ipv6_addresses       = optional(list(string))
    ipv6_prefix_count    = optional(number)
    ipv6_prefixes        = optional(list(string))
    network_card_index   = optional(number)
    network_interface_id = optional(string)
    primary_ipv6         = optional(bool)
    private_ip_address   = optional(string)
    security_groups      = optional(list(string), [])
    subnet_id            = optional(string)
  }))
  default = null
}

################################################################################
# Placement
################################################################################

variable "placement" {
  description = "Instance placement configuration"
  type = object({
    affinity                = optional(string)
    availability_zone       = optional(string)
    group_id                = optional(string)
    group_name              = optional(string)
    host_id                 = optional(string)
    host_resource_group_arn = optional(string)
    partition_number        = optional(number)
    spread_domain           = optional(string)
    tenancy                 = optional(string)
  })
  default = null
}

variable "placement_group" {
  description = "Placement group name for launched instances"
  type        = string
  default     = null
}

################################################################################
# CPU Options
################################################################################

variable "cpu_options" {
  description = "CPU options for instances (core count, threads per core)"
  type = object({
    amd_sev_snp      = optional(string)
    core_count       = optional(number)
    threads_per_core = optional(number)
  })
  default = null
}

variable "credit_specification" {
  description = "CPU credit option for T-type instances: standard or unlimited"
  type = object({
    cpu_credits = optional(string)
  })
  default = null
}

################################################################################
# Metadata Options
# EXAM: IMDSv2 (http_tokens=required) = secure, protects against SSRF attacks
# EXAM: Always use IMDSv2 — it is AWS security best practice
################################################################################

variable "metadata_options" {
  description = "Instance metadata service options. IMDSv2 enforced by default."
  type = object({
    http_endpoint               = optional(string, "enabled")
    http_protocol_ipv6          = optional(string)
    http_put_response_hop_limit = optional(number, 1)
    http_tokens                 = optional(string, "required")
    instance_metadata_tags      = optional(string)
  })
  default = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
}

################################################################################
# Capacity Reservation
################################################################################

variable "capacity_reservation_specification" {
  description = "Capacity reservation targeting option"
  type = object({
    capacity_reservation_preference = optional(string)
    capacity_reservation_target = optional(object({
      capacity_reservation_id                 = optional(string)
      capacity_reservation_resource_group_arn = optional(string)
    }))
  })
  default = null
}

################################################################################
# Spot + Market Options
# EXAM: Spot instances = up to 90% cheaper, can be interrupted
# EXAM: Mixed instances policy = combine on-demand + spot for cost savings
################################################################################

variable "instance_market_options" {
  description = "Market (purchasing) option for instances. Use for spot configuration."
  type = object({
    market_type = optional(string)
    spot_options = optional(object({
      block_duration_minutes         = optional(number)
      instance_interruption_behavior = optional(string)
      max_price                      = optional(string)
      spot_instance_type             = optional(string)
      valid_until                    = optional(string)
    }))
  })
  default = null
}

variable "use_mixed_instances_policy" {
  description = "Use mixed instances policy (combine on-demand + spot)"
  type        = bool
  default     = false
}

variable "mixed_instances_policy" {
  description = "Mixed instances policy configuration"
  type        = any
  default     = null
}

variable "instance_requirements" {
  description = "Attribute-based instance type selection. Cannot use with instance_type."
  type        = any
  default     = null
}

################################################################################
# Instance Refresh
# EXAM: Instance refresh = rolling update of ASG instances (zero downtime)
# EXAM: Rolling strategy = replaces % of instances at a time
################################################################################

variable "instance_refresh" {
  description = "Instance refresh configuration for rolling updates"
  type = object({
    strategy = string
    triggers = optional(list(string))
    preferences = optional(object({
      alarm_specification = optional(object({
        alarms = optional(list(string))
      }))
      auto_rollback                = optional(bool)
      checkpoint_delay             = optional(number)
      checkpoint_percentages       = optional(list(number))
      instance_warmup              = optional(number)
      max_healthy_percentage       = optional(number)
      min_healthy_percentage       = optional(number)
      scale_in_protected_instances = optional(string)
      skip_matching                = optional(bool)
      standby_instances            = optional(string)
    }))
  })
  default = null
}

################################################################################
# Lifecycle Hooks
# EXAM: Lifecycle hooks = pause ASG at launch/terminate for custom actions
# EXAM: Example: run scripts, drain connections before termination
################################################################################

variable "initial_lifecycle_hooks" {
  description = "Lifecycle hooks to attach before instances are launched"
  type = list(object({
    default_result          = optional(string)
    heartbeat_timeout       = optional(number)
    lifecycle_transition    = string
    name                    = string
    notification_metadata   = optional(string)
    notification_target_arn = optional(string)
    role_arn                = optional(string)
  }))
  default = null
}

################################################################################
# Instance Maintenance Policy
################################################################################

variable "instance_maintenance_policy" {
  description = "Instance maintenance policy with min/max healthy percentages"
  type = object({
    max_healthy_percentage = number
    min_healthy_percentage = number
  })
  default = null
}

################################################################################
# Warm Pool
################################################################################

variable "warm_pool" {
  description = "Warm pool configuration for pre-initialized instances"
  type = object({
    instance_reuse_policy = optional(object({
      reuse_on_scale_in = optional(bool)
    }))
    max_group_prepared_capacity = optional(number)
    min_size                    = optional(number)
    pool_state                  = optional(string)
  })
  default = null
}

################################################################################
# Scaling Policies
# EXAM: Scaling policies types:
#   - Target Tracking: maintain a metric at target value (e.g. CPU at 60%)
#   - Step Scaling: scale by steps based on alarm breach
#   - Simple Scaling: single adjustment per alarm
#   - Predictive Scaling: ML-based future scaling
################################################################################

variable "scaling_policies" {
  description = "Map of scaling policies to create (Target Tracking, Step, Simple, Predictive)"
  type        = any
  default     = null
}

################################################################################
# Schedules
# EXAM: Scheduled scaling = scale at known times (e.g. scale up Monday 9am)
################################################################################

variable "schedules" {
  description = "Map of scheduled scaling actions"
  type = map(object({
    desired_capacity = optional(number)
    end_time         = optional(string)
    max_size         = optional(number)
    min_size         = optional(number)
    recurrence       = optional(string)
    start_time       = optional(string)
    time_zone        = optional(string)
  }))
  default = null
}

################################################################################
# Traffic Source (ALB Target Group)
# EXAM: Traffic source = connects ASG to ALB target group for health checks
################################################################################

variable "traffic_source_attachments" {
  description = "Map of traffic source (ALB target group) attachments"
  type = map(object({
    traffic_source_identifier = string
    traffic_source_type       = optional(string, "elbv2")
  }))
  default = null
}

################################################################################
# Tag Specifications
################################################################################

variable "tag_specifications" {
  description = "Tags to apply to resources at launch (instance, volume, spot-request)"
  type = list(object({
    resource_type = optional(string)
    tags          = optional(map(string), {})
  }))
  default = null
}

################################################################################
# IAM Instance Profile
# EXAM: Instance profile = how ASG instances get IAM permissions
# EXAM: Never hardcode credentials — use instance profiles
################################################################################

variable "create_iam_instance_profile" {
  description = "Create IAM instance profile and role for ASG instances"
  type        = bool
  default     = false
}

variable "iam_instance_profile_arn" {
  description = "ARN of existing IAM instance profile (when create_iam_instance_profile=false)"
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "Name of IAM instance profile to create or use"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of permissions boundary policy for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Map of IAM policy ARNs to attach to the instance role"
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "Additional tags for the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_use_name_prefix" {
  description = "Use iam_role_name as prefix"
  type        = bool
  default     = true
}

################################################################################
# Advanced Options
################################################################################

variable "hibernation_options" {
  description = "Hibernation options for instances"
  type = object({
    configured = optional(bool)
  })
  default = null
}

variable "enclave_options" {
  description = "Enable Nitro Enclaves on launched instances"
  type = object({
    enabled = optional(bool)
  })
  default = null
}

variable "maintenance_options" {
  description = "Maintenance options for instances"
  type = object({
    auto_recovery = optional(string)
  })
  default = null
}

variable "private_dns_name_options" {
  description = "Private DNS hostname options for instances"
  type = object({
    enable_resource_name_dns_aaaa_record = optional(bool)
    enable_resource_name_dns_a_record    = optional(bool)
    hostname_type                        = optional(string)
  })
  default = null
}

variable "license_specifications" {
  description = "License specifications to associate with instances"
  type = list(object({
    license_configuration_arn = string
  }))
  default = null
}

variable "network_performance_options" {
  description = "Network performance options for the launch template"
  type = object({
    bandwidth_weighting = optional(string)
  })
  default = null
}
