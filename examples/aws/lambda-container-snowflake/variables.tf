variable "aembit_tenant_id" {
  type        = string
  description = "ID of Aembit tenant."
}

variable "vpc_id" {
  type        = string
  description = "ID of AWS VPC where Aembit edge components will be deployed."
}

variable "subnet_ids" {
  type        = set(string)
  description = "List of subnet IDs where Aembit edge components will be deployed."
}

variable "aws_account_id" {
  type        = string
  description = "ID of AWS where Aembit edge components will be deployed."
}

variable "aws_region" {
  type        = string
  description = "AWS region where Aembit edge components will be deployed."
}

variable "snowflake_account_id" {
  type        = string
  description = "Snowflake account ID for Lambda function to query."
}

variable "snowflake_username" {
  type        = string
  description = "Snowflake username for Lambda function authentication."
}

variable "snowflake_warehouse" {
  type        = string
  description = "Snowflake warehouse for Lambda function to query."
  default     = "COMPUTE_WH"
}

variable "snowflake_database" {
  type        = string
  description = "Snowflake database for Lambda function to query."
  default     = "SNOWFLAKE_SAMPLE_DATA"
}

variable "snowflake_schema" {
  type        = string
  description = "Snowflake schema for Lambda function to query."
  default     = "TPCH_SF1"
}

variable "snowflake_query" {
  type        = string
  description = "Snowflake query for Lambda function to run."
  default     = "SELECT \"C_NAME\", \"C_ACCTBAL\" FROM CUSTOMER;"
}

variable "aembit_agent_log_level" {
  type        = string
  description = "Log level of Aembit agent proxy Lambda extension."
  default     = "debug"
}

variable "aembit_agent_controller_url" {
  type        = string
  description = "FQDN of Aembit Agent Controller."
}

variable "create_snowflake_user" {
  type        = bool
  description = "Boolean indicating if a new Snowflake user should be created."
}
