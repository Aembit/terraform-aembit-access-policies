locals {
  ecr_address                    = format("%v.dkr.ecr.%v.amazonaws.com", var.aws_account_id, var.aws_region)
  ecr_image_uri                  = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.example.id, local.image_tag)
  image_tag                      = "latest"
  lambda_source_hash             = base64sha256(join("", [for f in fileset("src", "*") : filebase64sha256("src/${f}")]))
  name                           = "ex-${basename(path.cwd)}"
  snowflake_host                 = "${var.snowflake_account_id}.snowflakecomputing.com"
  snowflake_server_workload_name = "snowflake-sdk-${var.snowflake_account_id}"
  rsa_public_key                 = replace(split("=", module.aembit_lambda_container.credential_providers["snowflake"].snowflake_jwt.alter_user_command)[1], "'", "")
}


# Create Aembit Server Workload for the Snowflake SDK
resource "aembit_server_workload" "snowflake" {
  name        = local.snowflake_server_workload_name
  description = local.snowflake_server_workload_name
  is_active   = true
  service_endpoint = {
    app_protocol       = "Snowflake"
    host               = local.snowflake_host
    port               = 443
    requested_port     = 443
    tls                = true
    tls_verification   = "full"
    requested_tls      = true
    transport_protocol = "TCP"
    authentication_config = {
      method = "JWT Token Authentication"
      scheme = "Snowflake JWT"
    }
  }
}

# Create example Lambda function and associated AWS resources
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.aws_account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:*"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_ecr_repository" "example" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"
}

resource "null_resource" "build" {
  triggers = {
    source_hash = local.lambda_source_hash
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/container_build.sh"
  }
}

resource "aws_security_group" "lambda" {
  name_prefix = local.name
  description = "Allow all outbound traffic for Lambda function."
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports and protocols
}

resource "aws_lambda_function" "example" {
  depends_on    = [null_resource.build]
  architectures = ["x86_64", ]
  function_name = local.name

  image_uri    = local.ecr_image_uri
  package_type = "Image"

  role        = aws_iam_role.iam_for_lambda.arn
  timeout     = 60
  memory_size = 256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      SNOWFLAKE_ACCOUNT       = var.snowflake_account_id
      SNOWFLAKE_USERNAME      = var.snowflake_username
      SNOWFLAKE_HOST          = local.snowflake_host
      SNOWFLAKE_WAREHOUSE     = var.snowflake_warehouse
      SNOWFLAKE_DATABASE      = var.snowflake_database
      SNOWFLAKE_SCHEMA        = var.snowflake_schema
      SNOWFLAKE_QUERY         = var.snowflake_query
      AEMBIT_AGENT_CONTROLLER = var.aembit_agent_controller_url
      AEMBIT_LOG              = var.aembit_agent_log_level
      http_proxy              = "http://localhost:8000"
      https_proxy             = "http://localhost:8000"
      # This variable is only required for Python applications using the requests package
      REQUESTS_CA_BUNDLE = "/etc/pki/tls/certs/ca-bundle.crt"
    }
  }
}

# Create Aembit access policy for Lambda function
module "aembit_lambda_container" {
  depends_on                  = [aembit_server_workload.snowflake]
  source                      = "../../../"
  create_client_workload      = true
  create_trust_providers      = true
  create_credential_providers = true
  client_workload_identities = [
    {
      type  = "awsLambdaArn"
      value = aws_lambda_function.example.arn
    },
    # This enables aliased function invocation
    {
      type  = "awsLambdaArn"
      value = "${aws_lambda_function.example.arn}:*"
    }
  ]
  access_policies = {
    snowflake = {
      is_active                = true
      server_workload_name     = local.snowflake_server_workload_name
      credential_provider_name = "snowflake"
    }
  }
  trust_providers = {
    aws_role = {
      type = "aws_role"
      aws_role = {
        account_id = var.aws_account_id
        role_arn   = "arn:aws:sts::${var.aws_account_id}:assumed-role/${aws_iam_role.iam_for_lambda.name}/${aws_lambda_function.example.function_name}"
      }
    }
  }
  client_workload_name = local.name
  credential_providers = {
    snowflake = {
      is_active = true
      type      = "snowflake_jwt"
      snowflake_jwt = {
        account_id = var.snowflake_account_id
        username   = var.snowflake_username
      }
    }
  }
}

# Create Snowflake user or configure public key for existing user
resource "snowflake_user" "user" {
  count        = var.create_snowflake_user ? 1 : 0
  name         = var.snowflake_username
  login_name   = var.snowflake_username
  comment      = "Aembit Snowflake Terraform Example User."
  disabled     = "false"
  display_name = var.snowflake_username

  default_warehouse = var.snowflake_warehouse
  rsa_public_key    = local.rsa_public_key
}

resource "snowflake_user_public_keys" "user" {
  count          = var.create_snowflake_user ? 0 : 1
  name           = var.snowflake_username
  rsa_public_key = local.rsa_public_key
}
