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

  aembit_tenantid = var.aembit_tenant_id
  aembit_agent_controller_id = aembit_agent_controller.ecs.id

  ecs_cluster = aws_ecs_cluster.example[0].id
  ecs_vpc_id = try(module.vpc[0].vpc_id, var.vpc_id)
  ecs_subnets = try(module.vpc[0].private_subnets, var.subnet_ids)
  ecs_security_groups = try([aws_security_group.controller[0].id], var.controller_security_group_ids)
}

resource "aembit_role" "lambda" {
  name = "lambda-quickstart-role"
  access_authorization_events = {
    read = false
  }
  access_conditions = {
    read  = true
    write = false
  }
  access_policies = {
    read  = true
    write = false
  }
  agent_controllers = {
    read  = true
    write = false
  }
  audit_logs = {
    read = false
  }
  client_workloads = {
    read  = true
    write = false
  }
  credential_providers = {
    read  = true
    write = false
  }
  identity_providers = {
    read  = false
    write = false
  }
  integrations = {
    read  = true
    write = false
  }
  log_streams = {
    read  = false
    write = false
  }
  roles = {
    read  = true
    write = false
  }
  server_workloads = {
    read  = true
    write = false
  }
  trust_providers = {
    read  = true
    write = false
  }
  users = {
    read  = true
    write = false
  }
  workload_events = {
    read = false
  }
}

resource "aembit_server_workload" "aembit" {
  name        = local.aembit_server_workload_name
  description = "Aembit Cloud API for tenant ${var.aembit_tenant_id}"
  is_active   = true
  service_endpoint =  {
    app_protocol      = "HTTP"
    host              = "${var.aembit_tenant_id}.aembit.io"
    port              = 443
    requested_port    = 443
    tls               = true
    tls_verification = "full"
    requested_tls     = true
    transport_protocol = "TCP"
    authentication_config = {
      method = "HTTP Authentication"
      scheme = "Bearer"
    }
  }
}

resource "aembit_server_workload" "snowflake" {
  name        = lower(local.snowflake_server_workload_name)
  description = "${var.snowflake_host} Snowflake SDK"
  is_active   = true
  service_endpoint = {
    app_protocol      = "Snowflake"
    host              = lower(var.snowflake_host)
    port              = 443
    requested_port    = 443
    tls               = true
    tls_verification = "full"
    requested_tls     = true
    transport_protocol = "TCP"
    authentication_config = {
      method = "JWT Token Authentication"
      scheme = "Snowflake JWT"
    }
  }
}
