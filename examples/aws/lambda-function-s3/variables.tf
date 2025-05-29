variable "aembit_tenant_id" {
  type        = string
  description = "ID of Aembit tenant."
  default     = "f5dc61"
}

variable "vpc_id" {
  type        = string
  description = "ID of AWS VPC where Aembit edge components will be deployed."
  default     = "vpc-0b964775814fc8bc2"
}

variable "subnet_ids" {
  type        = set(string)
  description = "List of subnet IDs where Aembit edge components will be deployed."
  default     = ["subnet-0f54e8ccb262cb019", "subnet-058eeda618404db35"]
}

variable "aws_account_id" {
  type        = string
  description = "ID of AWS where Aembit edge components will be deployed."
}

variable "aws_region" {
  type        = string
  description = "AWS region where Aembit edge components will be deployed."
}

variable "aembit_agent_log_level" {
  type        = string
  description = "Log level of Aembit agent proxy Lambda extension."
  default     = "info"
}

variable "aembit_agent_controller_url" {
  type        = string
  description = "FQDN of Aembit Agent Controller."
  default     = "https://agent-controller.aembit.local:443"
}
