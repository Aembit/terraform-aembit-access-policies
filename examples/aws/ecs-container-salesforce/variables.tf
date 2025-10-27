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

variable "salesforce_host" {
  type        = string
  description = "FQDN of Salesforce instance."
}

variable "salesforce_client_id" {
  type        = string
  description = "Client ID of Salesforce Oauth app."
}

variable "salesforce_client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of Salesforce Oauth app."
}

variable "salesforce_oauth_scopes" {
  type        = string
  description = "Set of Salesforce Oauth scopes for Credential Provider."
  default     = "full offline_access refresh_token openid"
}

variable "aembit_agent_log_level" {
  type        = string
  description = "Log level of Aembit agent proxy Lambda extension."
  default     = "info"
}
