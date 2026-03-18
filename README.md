# terraform-rohanmatre-asg

Terraform wrapper module for AWS Auto Scaling Groups — built on top of [terraform-aws-modules/autoscaling/aws](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws).

This wrapper adds:
- **Auto naming** → `rohanmatre-{environment}-{region}-asg`
- **Auto tagging** → `Environment`, `Owner`, `GitHubRepo`, `ManagedBy`
- **Env-aware monitoring** → detailed monitoring auto-enabled in prod
- **Env-aware instance refresh** → Rolling strategy auto-configured in prod
- **Safe defaults** → `t3.micro`, `min=1`, `max=3`, `desired=1`, IMDSv2 enforced

---

## Dependencies

```hcl
vpc_zone_identifier = module.vpc.private_subnet_ids  # rohanmatre-vpc-wrapper
security_groups     = [module.sg.security_group_id]  # rohanmatre-sg-wrapper
```

---

## Usage

### Basic (dev)

```hcl
module "asg" {
  source  = "rohanmatre007dev-sys/asg/rohanmatre"
  version = "1.0.0"

  environment         = "dev"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = module.vpc.private_subnet_ids
  security_groups     = [module.sg.security_group_id]
  instance_type       = "t3.micro"
}
```

### Advanced (prod with scaling policies + schedules)

```hcl
module "asg" {
  source  = "rohanmatre007dev-sys/asg/rohanmatre"
  version = "1.0.0"

  environment         = "prod"
  min_size            = 2
  max_size            = 10
  desired_capacity    = 2
  vpc_zone_identifier = module.vpc.private_subnet_ids
  security_groups     = [module.sg.security_group_id]
  instance_type       = "t3.small"
  health_check_type   = "ELB"

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
}
```

---

## Environment-Aware Behavior

| Setting | dev / stage | prod |
|---|---|---|
| Detailed monitoring | Off by default | Auto-enabled |
| Instance refresh | Not configured | Auto: Rolling, 50% min healthy |
| Health check grace period | User-defined | Auto: 300 seconds |

---

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `create` | Controls whether resources will be created | `bool` | `true` |
| `region` | AWS region | `string` | `"ap-south-1"` |
| `environment` | Environment: dev, stage, prod | `string` | `"dev"` |
| `name` | ASG name. Auto-generated if null | `string` | `null` |
| `min_size` | Minimum number of instances | `number` | `1` |
| `max_size` | Maximum number of instances | `number` | `3` |
| `desired_capacity` | Desired number of instances | `number` | `1` |
| `vpc_zone_identifier` | Subnet IDs from rohanmatre-vpc-wrapper | `list(string)` | `null` |
| `security_groups` | SG IDs from rohanmatre-sg-wrapper | `list(string)` | `[]` |
| `health_check_type` | EC2 or ELB | `string` | `"EC2"` |
| `instance_type` | EC2 instance type | `string` | `"t3.micro"` |
| `image_id` | AMI ID. Uses SSM latest if null | `string` | `null` |
| `scaling_policies` | Map of scaling policies | `any` | `null` |
| `schedules` | Map of scheduled scaling actions | `map(object)` | `null` |
| `tags` | Additional tags | `map(string)` | `{}` |

Full list: [variables.tf](variables.tf)

---

## Outputs

| Name | Description | Consumed By |
|---|---|---|
| `autoscaling_group_id` | ASG ID | CloudWatch alarms, ALB |
| `autoscaling_group_name` | ASG name | Reference |
| `autoscaling_group_arn` | ASG ARN | IAM policies |
| `autoscaling_group_target_group_arns` | Target group ARNs | ALB wrapper |
| `launch_template_id` | Launch template ID | Other ASGs |
| `iam_role_arn` | IAM role ARN | Cross-account policies |

Full list: [outputs.tf](outputs.tf)

---

## Notes

- Auto-generates name as `rohanmatre-{environment}-{region}-asg`
- IMDSv2 always enforced (`http_tokens=required`)
- Set `health_check_type=ELB` when ASG is behind an ALB
- Upstream module: [terraform-aws-modules/autoscaling/aws >= 6.29](https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws)
- Default region: `ap-south-1`

---

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.5.7 |
| aws | >= 6.29 |
