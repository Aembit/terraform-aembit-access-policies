locals {
  ecr_address           = format("%v.dkr.ecr.%v.amazonaws.com", var.aws_account_id, var.aws_region)
  ecr_image_uri         = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.example.id, local.image_tag)
  image_tag             = "latest"
  container_source_hash = base64sha256(join("", [for f in fileset("src", "*") : filebase64sha256("src/${f}")]))
  name                  = "ex-${basename(path.cwd)}"
}


# Create Aembit Server Workload for the salesforce SDK
resource "aembit_server_workload" "salesforce" {
  name        = var.salesforce_host
  description = var.salesforce_host
  is_active   = true
  service_endpoint = {
    app_protocol       = "HTTP"
    host               = var.salesforce_host
    port               = 443
    requested_port     = 443
    tls                = true
    tls_verification   = "full"
    requested_tls      = true
    transport_protocol = "TCP"
    authentication_config = {
      method = "HTTP Authentication"
      scheme = "Bearer"
    }
  }
}

# Create example ECS task and associated AWS resources
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.aws_account_id]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.iam_for_ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "iam_for_ecs" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_ecr_repository" "example" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"
}

resource "null_resource" "build" {
  triggers = {
    source_hash = local.container_source_hash
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/container_build.sh"
    environment = {
      "AWS_ACCOUNT_ID"   = var.aws_account_id
      "AWS_REGION"       = var.aws_region
      "AEMBIT_TENANT_ID" = var.aembit_tenant_id
      "IMAGE_NAME"       = local.name
    }
  }
}

resource "aws_security_group" "ecs" {
  name_prefix = local.name
  description = "Allow all outbound traffic for ECS task."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.ecs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports and protocols
}

# Log Group Resource (Optional)
resource "aws_cloudwatch_log_group" "salesforce_client" {

  name              = "ecs-${local.name}"
  retention_in_days = 30
}

##########################################################################################
# AgentController Task & Service
resource "aws_ecs_task_definition" "salesforce_client" {
  depends_on = [null_resource.build]
  family     = local.name
  container_definitions = jsonencode([
    jsondecode(module.aembit-ecs.agent_proxy_container),
    {
      name      = local.name
      image     = local.ecr_image_uri
      essential = true
      # dependsOn = [
      #   {
      #     containerName = jsondecode(module.aembit-ecs.agent_proxy_container).name
      #     condition     = "HEALTHY" # proxy must define a healthCheck
      #   }
      # ]
      environment = [
        { "name" : "http_proxy", "value" : module.aembit-ecs.aembit_http_proxy },
        { "name" : "https_proxy", "value" : module.aembit-ecs.aembit_http_proxy },
        { "name" : "REQUESTS_CA_BUNDLE", "value" : "/etc/ssl/certs/ca-certificates.crt" },
        { "name" : "SF_INSTANCE_URL", "value" : "${var.salesforce_host}" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.salesforce_client.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = local.name
        }
      }
  }])
  task_role_arn            = aws_iam_role.iam_for_ecs.arn
  execution_role_arn       = aws_iam_role.iam_for_ecs.arn
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "salesforce_client" {
  name                   = local.name
  desired_count          = 1
  launch_type            = "FARGATE"
  cluster                = aws_ecs_cluster.example.id
  task_definition        = aws_ecs_task_definition.salesforce_client.arn
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
  }
}


# Create Aembit access policy for ECS task
module "aembit_ecs_container" {
  depends_on                  = [aembit_server_workload.salesforce]
  source                      = "../../../"
  create_client_workload      = true
  create_trust_providers      = true
  create_credential_providers = true
  client_workload_identifiers = [
    {
      type  = "awsEcsTaskFamily"
      value = local.name
    }
  ]
  access_policies = {
    salesforce = {
      is_active                = true
      server_workload_name     = var.salesforce_host
      credential_provider_name = "salesforce"
    }
  }
  trust_providers = {
    aws_role = {
      type = "aws_role"
      aws_role = {
        account_id = var.aws_account_id
        role_arn   = "arn:aws:sts::${var.aws_account_id}:assumed-role/${aws_iam_role.iam_for_ecs.name}/*"
      }
    }
  }
  client_workload_name = local.name
  credential_providers = {
    salesforce = {
      is_active = true
      type      = "oauth_authorization_code"
      oauth_authorization_code = {
        client_id               = var.salesforce_client_id
        client_secret           = var.salesforce_client_secret
        oauth_authorization_url = "https://${var.salesforce_host}/services/oauth2/authorize"
        oauth_discovery_url     = "https://${var.salesforce_host}/"
        oauth_token_url         = "https://${var.salesforce_host}/services/oauth2/token"
        scopes                  = var.salesforce_oauth_scopes
        is_pkce_required        = true
        oauth_introspection_url = "https://${var.salesforce_host}/services/oauth2/introspect"
      }
    }
  }
}
