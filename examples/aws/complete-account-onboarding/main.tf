# Create AWS VPC 
data "aws_vpc" "selected" {
  count = var.create_vpc ? 0 : 1
  id    = var.vpc_id
}

module "vpc" {
  count   = var.create_vpc ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = var.vpc_name
  cidr = "192.168.0.0/16"

  azs             = ["us-west-2a"]
  private_subnets = ["192.168.1.0/24"]
  public_subnets  = ["192.168.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
}

# Create AWS ECS cluster to host Aembit Agent Controller
resource "aws_ecs_cluster" "example" {
  count = var.create_ecs_cluster ? 1 : 0
  name  = "ecs_aembit_demo"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create Aembit Agent Controller
resource "aembit_agent_controller" "ecs" {
  name      = "Agent Controller with ECS Trust Provider"
  is_active = true

  trust_provider_id = aembit_trust_provider.ecs.id
}

resource "aembit_trust_provider" "ecs" {
  name      = "AWS Role Trust Provider"
  is_active = true
  aws_role = {
    account_id = var.aws_account_id
  }
}

module "aembit-ecs" {
  source  = "Aembit/ecs/aembit"
  version = "1.17.4" # Find the latest version at https://registry.terraform.io/modules/Aembit/ecs/aembit/latest

  aembit_tenantid            = var.aembit_tenant_id
  aembit_agent_controller_id = aembit_agent_controller.ecs.id

  ecs_cluster         = try(aws_ecs_cluster.example[0].id, var.ecs_cluster_id)
  ecs_vpc_id          = try(module.vpc[0].vpc_id, var.vpc_id)
  ecs_subnets         = try(module.vpc[0].private_subnets, var.subnet_ids)
  ecs_security_groups = try([aws_security_group.controller[0].id], var.controller_security_group_ids)
}

resource "aws_security_group" "controller" {
  count       = var.controller_security_group_ids == null ? 1 : 0
  name_prefix = "ecs_aembit_controller"
  description = "Allow VPC traffic to Aembit controller and outbound internet for controller"
  vpc_id      = try(module.vpc[0].vpc_id, var.vpc_id)
}

resource "aws_vpc_security_group_ingress_rule" "controller_https_ipv4" {
  count             = var.controller_security_group_ids == null ? 1 : 0
  security_group_id = aws_security_group.controller[0].id
  cidr_ipv4         = try(module.vpc[0].vpc_cidr_block, data.aws_vpc.selected[0].cidr_block)
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "controller_http_ipv4" {
  count             = var.controller_security_group_ids == null ? 1 : 0
  security_group_id = aws_security_group.controller[0].id
  cidr_ipv4         = try(module.vpc[0].vpc_cidr_block, data.aws_vpc.selected[0].cidr_block)
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "controller_all_ipv4" {
  count             = var.controller_security_group_ids == null ? 1 : 0
  security_group_id = aws_security_group.controller[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create Aembit access policies for Lambda client workloads
module "lambda_workloads" {
  source   = "../../../"
  for_each = var.lambda_workloads

  create_client_workload      = true
  create_trust_providers      = true
  create_credential_providers = each.value["create_credential_providers"]
  client_workload_identifiers = [
    {
      type  = "awsLambdaArn"
      value = each.value["function_arn"]
    },
    # This enables aliased function invocation
    {
      type  = "awsLambdaArn"
      value = "${each.value["function_arn"]}:*"
    }
  ]
  access_policies = each.value["access_policies"]
  trust_providers = {
    aws_role = {
      type = "aws_role"
      aws_role = {
        account_id = var.aws_account_id
        role_arn   = "arn:aws:sts::${var.aws_account_id}:assumed-role/${each.value["function_role_name"]}/${each.value["function_name"]}"
      }
    }
  }
  client_workload_name = each.key
  credential_providers = each.value["credential_providers"]
}

# Create Aembit access policies for EC2 client workloads with an attached IAM role
module "ec2_workloads" {
  source   = "../../../"
  for_each = var.ec2_workloads

  create_client_workload      = true
  create_trust_providers      = true
  create_credential_providers = each.value["create_credential_providers"]
  client_workload_identifiers = each.value["client_workload_identifiers"]
  access_policies             = each.value["access_policies"]
  trust_providers = {
    aws_role = {
      type = "aws_role"
      aws_role = {
        account_id = var.aws_account_id
        role_arn   = "arn:aws:sts::${var.aws_account_id}:assumed-role/${each.value["iam_role_name"]}/*"
      }
    }
  }
  client_workload_name = each.key
  credential_providers = each.value["credential_providers"]
}

# Create Aembit access policies for ECS task client workloads
module "ecs_workloads" {
  source   = "../../../"
  for_each = var.ecs_workloads

  create_client_workload      = each.value["create_client_workload"]
  create_trust_providers      = each.value["create_trust_providers"]
  create_credential_providers = each.value["create_credential_providers"]
  client_workload_identifiers = [
    {
      type  = "awsEcsTaskFamily"
      value = each.value["ecs_task_family"]
    }
  ]
  access_policies = each.value["access_policies"]
  trust_providers = {
    aws_role = {
      type = "aws_role"
      aws_role = {
        account_id = var.aws_account_id
        role_arn   = "arn:aws:sts::${var.aws_account_id}:assumed-role/${each.value["iam_role_name"]}/*"
      }
    }
  }
  client_workload_name = each.key
  credential_providers = each.value["credential_providers"]
}
