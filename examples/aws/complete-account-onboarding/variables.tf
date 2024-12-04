variable "aembit_tenant_id" {
  type        = string
  description = "ID of Aembit tenant."
}

variable "aws_account_id" {
  type        = string
  description = "ID of AWS where Aembit edge components will be deployed."
}

variable "lambda_workloads" {
  type        = any
  description = "Map of Lambda workload access policy configurations"
  default     = {}
}

variable "ec2_workloads" {
  type        = any
  description = "Map of EC2 workload access policy configurations"
  default     = {}
}

variable "ecs_workloads" {
  type        = any
  description = "Map of ECS workload access policy configurations"
  default     = {}
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

variable "controller_security_group_ids" {
  type        = set(string)
  description = "List of AWS Security Group IDs to attach to Aembit Controller.  If this is not provided a security group will be created."
  default     = null
}

variable "ecs_cluster_id" {
  type        = string
  description = "ID of ECS cluster where Aembit Controller will be deployed."
  default     = ""
}

variable "create_vpc" {
  type        = bool
  description = "Boolean indicating whether a new VPC should be created.  If this is not provided the `vpc_id` variable is required."
}

variable "create_ecs_cluster" {
  type        = bool
  description = "Boolean indicating whether a new ECS cluster should be created.  If this is not provided the `ecs_cluster_id` variable is required."
}