################################################################################
# Autoscaling Group Outputs
################################################################################

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_id
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

output "autoscaling_group_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = module.asg.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Current desired number of instances"
  value       = module.asg.autoscaling_group_desired_capacity
}

output "autoscaling_group_availability_zones" {
  description = "Availability zones used by the ASG"
  value       = module.asg.autoscaling_group_availability_zones
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "Subnet IDs used by the ASG"
  value       = module.asg.autoscaling_group_vpc_zone_identifier
}

output "autoscaling_group_health_check_type" {
  description = "Health check type: EC2 or ELB"
  value       = module.asg.autoscaling_group_health_check_type
}

output "autoscaling_group_health_check_grace_period" {
  description = "Seconds after launch before health checks begin"
  value       = module.asg.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_default_cooldown" {
  description = "Seconds between consecutive scaling activities"
  value       = module.asg.autoscaling_group_default_cooldown
}

output "autoscaling_group_enabled_metrics" {
  description = "List of CloudWatch metrics enabled for collection"
  value       = module.asg.autoscaling_group_enabled_metrics
}

output "autoscaling_group_load_balancers" {
  description = "Load balancer names associated with the ASG"
  value       = module.asg.autoscaling_group_load_balancers
}

output "autoscaling_group_target_group_arns" {
  description = "Target Group ARNs attached to the ASG — consumed by ALB wrapper"
  value       = module.asg.autoscaling_group_target_group_arns
}

################################################################################
# Scaling Policies + Schedules
################################################################################

output "autoscaling_policy_arns" {
  description = "ARNs of all scaling policies created"
  value       = module.asg.autoscaling_policy_arns
}

output "autoscaling_schedule_arns" {
  description = "ARNs of all scheduled scaling actions created"
  value       = module.asg.autoscaling_schedule_arns
}

################################################################################
# Launch Template Outputs
# Consumed by: other ASGs that want to reuse this launch template
################################################################################

output "launch_template_id" {
  description = "ID of the launch template"
  value       = module.asg.launch_template_id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = module.asg.launch_template_arn
}

output "launch_template_name" {
  description = "Name of the launch template"
  value       = module.asg.launch_template_name
}

output "launch_template_default_version" {
  description = "Default version of the launch template"
  value       = module.asg.launch_template_default_version
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = module.asg.launch_template_latest_version
}

################################################################################
# IAM Outputs
################################################################################

output "iam_role_arn" {
  description = "ARN of the IAM role attached to ASG instances"
  value       = module.asg.iam_role_arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = module.asg.iam_role_name
}

output "iam_role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = module.asg.iam_role_unique_id
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = module.asg.iam_instance_profile_arn
}

output "iam_instance_profile_id" {
  description = "ID of the IAM instance profile"
  value       = module.asg.iam_instance_profile_id
}

output "iam_instance_profile_unique" {
  description = "Unique ID of the IAM instance profile"
  value       = module.asg.iam_instance_profile_unique
}
