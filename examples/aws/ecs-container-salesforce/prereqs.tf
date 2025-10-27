# Create AWS VPC 
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Create AWS ECS cluster to host Aembit Agent Controller
resource "aws_ecs_cluster" "example" {
  name = "ecs_aembit_demo"

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
  version = "1.22.1" # Find the latest version at https://registry.terraform.io/modules/Aembit/ecs/aembit/latest

  aembit_tenantid            = var.aembit_tenant_id
  aembit_agent_controller_id = aembit_agent_controller.ecs.id

  ecs_cluster         = aws_ecs_cluster.example.id
  ecs_vpc_id          = var.vpc_id
  ecs_subnets         = var.subnet_ids
  ecs_security_groups = [aws_security_group.controller.id]
}

resource "aws_security_group" "controller" {
  name_prefix = "ecs_aembit_controller"
  description = "Allow VPC traffic to Aembit controller and outbound internet for controller"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "controller_https_ipv4" {
  security_group_id = aws_security_group.controller.id
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "controller_http_ipv4" {
  security_group_id = aws_security_group.controller.id
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "controller_all_ipv4" {
  security_group_id = aws_security_group.controller.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
