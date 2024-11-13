I have some other stuff in this doc too

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5)

- <a name="requirement_aembit"></a> [aembit](#requirement\_aembit) (>= 1.17.0)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 5.0)

- <a name="requirement_null"></a> [null](#requirement\_null) (~> 3.0)

## Providers

The following providers are used by this module:

- <a name="provider_aembit"></a> [aembit](#provider\_aembit) (1.17.2)

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.73.0)

- <a name="provider_null"></a> [null](#provider\_null) (3.2.3)

## Modules

The following Modules are called:

### <a name="module_aembit-ecs"></a> [aembit-ecs](#module\_aembit-ecs)

Source: Aembit/ecs/aembit

Version: 1.17.4

### <a name="module_single_lambda"></a> [single\_lambda](#module\_single\_lambda)

Source: ../../

Version:

### <a name="module_vpc"></a> [vpc](#module\_vpc)

Source: terraform-aws-modules/vpc/aws

Version: 5.14.0

## Resources

The following resources are used by this module:

- [aembit_agent_controller.ecs](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/agent_controller) (resource)
- [aembit_trust_provider.ecs](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/trust_provider) (resource)
- [aws_cloudwatch_log_group.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) (resource)
- [aws_ecs_cluster.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) (resource)
- [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_lambda_function.quickstart](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) (resource)
- [aws_security_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_security_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_vpc_security_group_egress_rule.controller_all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) (resource)
- [aws_vpc_security_group_egress_rule.lambda_all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) (resource)
- [aws_vpc_security_group_ingress_rule.controller_http_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) (resource)
- [aws_vpc_security_group_ingress_rule.controller_https_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) (resource)
- [null_resource.build](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_aembit_tenant_id"></a> [aembit\_tenant\_id](#input\_aembit\_tenant\_id)

Description: ID of Aembit tenant.

Type: `string`

### <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id)

Description: ID of AWS where Aembit edge components will be deployed.

Type: `string`

### <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)

Description: AWS region where Aembit edge components will be deployed.

Type: `string`

### <a name="input_snowflake_account_id"></a> [snowflake\_account\_id](#input\_snowflake\_account\_id)

Description: Snowflake account ID for Lambda function to query.

Type: `string`

### <a name="input_snowflake_database"></a> [snowflake\_database](#input\_snowflake\_database)

Description: Snowflake database for Lambda function to query.

Type: `string`

### <a name="input_snowflake_host"></a> [snowflake\_host](#input\_snowflake\_host)

Description: FQDN of Snowflake instance.

Type: `string`

### <a name="input_snowflake_query"></a> [snowflake\_query](#input\_snowflake\_query)

Description: Snowflake query for Lambda function to run.

Type: `string`

### <a name="input_snowflake_schema"></a> [snowflake\_schema](#input\_snowflake\_schema)

Description: Snowflake schema for Lambda function to query.

Type: `string`

### <a name="input_snowflake_username"></a> [snowflake\_username](#input\_snowflake\_username)

Description: Snowflake username for Lambda function authentication.

Type: `string`

### <a name="input_snowflake_warehouse"></a> [snowflake\_warehouse](#input\_snowflake\_warehouse)

Description: Snowflake warehouse for Lambda function to query.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aembit_agent_log_level"></a> [aembit\_agent\_log\_level](#input\_aembit\_agent\_log\_level)

Description: Log level of Aembit agent proxy Lambda extension.

Type: `string`

Default: `"debug"`

### <a name="input_controller_security_group_ids"></a> [controller\_security\_group\_ids](#input\_controller\_security\_group\_ids)

Description: List of AWS Security Group IDs to attach to Aembit Controller.  If this is not provided a security group will be created.

Type: `set(string)`

Default: `null`

### <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name)

Description: Name of ECR repository to push/pull docker image to/from

Type: `string`

Default: `"aembit-lambda-snowflake-demo"`

### <a name="input_ecs_cluster_id"></a> [ecs\_cluster\_id](#input\_ecs\_cluster\_id)

Description: ID of ECS cluster where Aembit Controller will be deployed.  If this is not provided a ECS fargate cluster will be created.

Type: `string`

Default: `""`

### <a name="input_function_name"></a> [function\_name](#input\_function\_name)

Description: Name of Lambda function.

Type: `string`

Default: `"aembit-quickstart-lambda"`

### <a name="input_lambda_ca_bundle_path"></a> [lambda\_ca\_bundle\_path](#input\_lambda\_ca\_bundle\_path)

Description: Path in Lambda function to pem-encoded ca bundle file.  This file should contain all CAs your Lambda needs to trust, including your Aembit tenant's root CA.

Type: `string`

Default: `"/opt/trusted_roots.crt"`

### <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)

Description: List of subnet IDs where Aembit edge components will be deployed.

Type: `set(string)`

Default: `null`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: ID of AWS VPC where Aembit edge components will be deployed.

Type: `string`

Default: `""`

## Outputs

No outputs.
<!-- END_TF_DOCS -->