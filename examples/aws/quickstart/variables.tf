locals {
  lambda_source_hash = base64sha256(join("", [for f in fileset("src", "*") : filebase64sha256("src/${f}")]))
  snowflake_server_workload_name = "snowflake-sdk-${split(".", lower(var.snowflake_host))[0]}"
  aembit_server_workload_name = "aembit-${var.aembit_tenant_id}"
  # These variables are for running Lambda with an AWS managed runtime
  # ecr_address        = format("%v.dkr.ecr.%v.amazonaws.com", var.aws_account_id, var.aws_region)
  # image_tag          = "latest"
  # ecr_image_uri      = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.this.id, local.image_tag)
}

variable "aembit_tenant_id" {
  type        = string
  description = "ID of Aembit tenant."
}

variable "vpc_id" {
  type        = string
  description = "ID of AWS VPC where Aembit edge components will be deployed."
  default     = ""
}

variable "subnet_ids" {
  type        = set(string)
  description = "List of subnet IDs where Aembit edge components will be deployed."
  default     = null
}

variable "aws_account_id" {
  type        = string
  description = "ID of AWS where Aembit edge components will be deployed."
}

variable "aws_region" {
  type        = string
  description = "AWS region where Aembit edge components will be deployed."
}

variable "controller_security_group_ids" {
  type        = set(string)
  description = "List of AWS Security Group IDs to attach to Aembit Controller.  If this is not provided a security group will be created."
  default     = null
}

variable "ecs_cluster_id" {
  type        = string
  description = "ID of ECS cluster where Aembit Controller will be deployed.  If this is not provided a Fargate ECS cluster will be created."
  default     = ""
}

variable "snowflake_account_id" {
  type        = string
  description = "Snowflake account ID for Lambda function to query."
}

variable "snowflake_username" {
  type        = string
  description = "Snowflake username for Lambda function authentication."
}

variable "snowflake_host" {
  type        = string
  description = "FQDN of Snowflake instance."
}

variable "snowflake_warehouse" {
  type        = string
  description = "Snowflake warehouse for Lambda function to query."
}

variable "snowflake_database" {
  type        = string
  description = "Snowflake database for Lambda function to query."
}

variable "snowflake_schema" {
  type        = string
  description = "Snowflake schema for Lambda function to query."
}

variable "snowflake_query" {
  type        = string
  description = "Snowflake query for Lambda function to run."
}

variable "function_name" {
  type        = string
  description = "Name of Lambda function."
  default     = "aembit-quickstart-lambda"
}

variable "aembit_agent_log_level" {
  type        = string
  description = "Log level of Aembit agent proxy Lambda extension."
  default     = "debug"
}

variable "lambda_ca_bundle_path" {
  type        = string
  description = "Path in Lambda function to pem-encoded ca bundle file.  This file should contain all CAs your Lambda needs to trust, including your Aembit tenant's root CA."
  default     = "/opt/trusted_roots.crt"
}

variable "ecr_repository_name" {
  type        = string
  description = "Name of ECR repository to push/pull docker image to/from"
  default     = "aembit-lambda-snowflake-demo"
}

variable "lambda_layers" {
  type = set(string)
  description = "Set of Lambda Layer Arns to attach to the Lambda function."
  default = null
}
