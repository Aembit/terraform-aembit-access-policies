data "aws_vpc" "selected" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

module "vpc" {
  count   = var.vpc_id == "" ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "my-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["us-west-2a"]
  private_subnets = ["192.168.1.0/24"]
  public_subnets  = ["192.168.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
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

resource "aws_ecs_cluster" "example" {
  count = var.ecs_cluster_id == "" ? 1 : 0
  name  = "ecs_aembit_demo"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
