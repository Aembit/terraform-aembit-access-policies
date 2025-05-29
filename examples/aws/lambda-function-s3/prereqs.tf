# The resources in this file only need to be created once
# They can be reused across all future workloads

# Create Aembit Server Workload for the AWS S3 API
resource "aembit_server_workload" "s3" {
  name        = "aws-s3-example"
  description = "AWS S3"
  is_active   = true
  service_endpoint = {
    app_protocol       = "HTTP"
    host               = "s3.${var.aws_region}.amazonaws.com"
    port               = 443
    requested_port     = 443
    tls                = true
    tls_verification   = "full"
    requested_tls      = true
    transport_protocol = "TCP"
    authentication_config = {
      method = "HTTP Authentication"
      scheme = "AWS Signature v4"
    }
  }
}

# Create Lambda Layer with CA trust bundle
resource "null_resource" "trust_bundle" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/layer_build.sh"
    environment = {
      "AEMBIT_TENANT_ID" = var.aembit_tenant_id
    }
  }
}

resource "aws_lambda_layer_version" "trust_bundle" {
  depends_on = [null_resource.trust_bundle]
  filename   = "${path.module}/build/trustbundle.zip"
  layer_name = "ca_trust_bundle"

  source_code_hash = "${path.module}/build/trustbundle.zip"
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "aembit_proxy_layer" {
  name           = "aembit-agent-proxy-lambda-layer"
  application_id = "arn:aws:serverlessrepo:us-east-1:833062290399:applications/aembit-agent-proxy-lambda-layer"
  capabilities   = ["CAPABILITY_IAM"]
}
