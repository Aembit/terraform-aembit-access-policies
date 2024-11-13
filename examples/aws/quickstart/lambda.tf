data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:SourceAccount"
    #   values   = [var.aws_account_id]
    # }

    # condition {
    #   test     = "ArnLike"
    #   variable = "aws:SourceArn"
    #   values   = ["arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.function_name}"]
    # }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = var.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# This resource is for runninng Lambda with an AWS managed runtime
resource "null_resource" "build" {
  triggers = {
    source_hash = local.lambda_source_hash
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/function_build.sh"
  }
}

# These resources are for running Lambda with a custom container image
# resource "aws_ecr_repository" "this" {
#   name                 = var.ecr_repository_name
#   image_tag_mutability = "MUTABLE"
# }

# resource "null_resource" "build" {
#   triggers = {
#     source_hash = local.lambda_source_hash
#   }

#   provisioner "local-exec" {
#     command = "bash ${path.module}/container_build.sh"
#   }
# }

resource "aws_security_group" "lambda" {
  name_prefix = var.function_name
  description = "Allow all outbound traffic for Lambda function."
  vpc_id      = try(module.vpc[0].vpc_id, var.vpc_id)
}

resource "aws_vpc_security_group_egress_rule" "lambda_all_ipv4" {
  security_group_id = aws_security_group.lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports and protocols
}

resource "aws_lambda_layer_version" "requirements" {
  depends_on       = [null_resource.build]
  layer_name = "aembit-quickstart-lambda-python-reqs"
  filename = "${path.module}/artifacts/requirements.zip"
  compatible_runtimes = ["python3.9"]
  source_code_hash = local.lambda_source_hash
}

resource "aws_lambda_function" "quickstart" {
  architectures = ["x86_64", ]
  function_name = var.function_name
  # These arguments are for running Lambda with an AWS managed runtime
  depends_on       = [null_resource.build]
  filename         = "${path.module}/artifacts/lambda.zip"
  layers           = setunion(var.lambda_layers, [aws_lambda_layer_version.requirements.arn])
  source_code_hash = local.lambda_source_hash
  runtime          = "python3.9"
  handler          = "handler.lambda_handler"

  # These arguments are for running Lambda with a custom container image
  # image_uri     = local.ecr_image_uri
  # package_type  = "Image"

  role        = aws_iam_role.iam_for_lambda.arn
  timeout     = 60
  memory_size = 256



  vpc_config {
    subnet_ids         = try(module.vpc[0].private_subnets, var.subnet_ids)
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      SNOWFLAKE_ACCOUNT       = var.snowflake_account_id
      SNOWFLAKE_USERNAME      = var.snowflake_username
      SNOWFLAKE_HOST          = var.snowflake_host
      SNOWFLAKE_WAREHOUSE     = var.snowflake_warehouse
      SNOWFLAKE_DATABASE      = var.snowflake_database
      SNOWFLAKE_SCHEMA        = var.snowflake_schema
      SNOWFLAKE_QUERY         = var.snowflake_query
      AEMBIT_AGENT_CONTROLLER = jsondecode(module.aembit-ecs.agent_proxy_container).environment[0].value
      http_proxy              = "http://localhost:8000"
      https_proxy             = "http://localhost:8000"
      AEMBIT_LOG              = var.aembit_agent_log_level
      REQUESTS_CA_BUNDLE      = var.lambda_ca_bundle_path
      SSL_CERT_FILE           = var.lambda_ca_bundle_path
    }
  }
}

# single lambda function
module "single_lambda" {
  depends_on = [ aembit_server_workload.aembit, aembit_server_workload.snowflake ]
  source                      = "../../../"
  create_client_workload      = true
  create_trust_providers      = true
  create_credential_providers = true
  client_workload_identities = [
    {
      type  = "awsLambdaArn"
      value = aws_lambda_function.quickstart.arn
    },
    # This enables aliased function invocation
    {
      type  = "awsLambdaArn"
      value = "${aws_lambda_function.quickstart.arn}:*"
    }
  ]
  access_policies = {
    aembit = {
      is_active = true
      server_workload_name = local.aembit_server_workload_name
      credential_provider_name = "aembit"
    }
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
        role_arn   = "arn:aws:sts::${var.aws_account_id}:assumed-role/${aws_iam_role.iam_for_lambda.name}/${aws_lambda_function.quickstart.function_name}"
      }
    }
  }
  client_workload_name = var.function_name
  credential_providers = {
    aembit = {
      is_active = true
      type = "aembit_access_token"
      aembit_access_token = {
        lifetime = 900
        role_id = aembit_role.lambda.id
      }
    }
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
