output "agent_controller_fqdn" {
  description = "DNS Name of Aembit Agent Controller"
  value       = jsondecode(module.aembit-ecs.agent_proxy_container).environment[0].value
}

output "vpc_id" {
  description = "AWS VPC ID where Agent Controller is hosted"
  value       = try(module.vpc[0].vpc_id, var.vpc_id)
}

output "subnet_ids" {
  description = "AWS subnet IDs where Agent Controller is hosted"
  value       = try(module.vpc[0].private_subnets, var.subnet_ids)
}