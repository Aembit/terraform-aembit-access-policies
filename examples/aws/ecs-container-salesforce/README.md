# Lambda Container Using Aembit to Access Snowflake
Configuration in this directory creates an Aembit Access Policy and AWS Lambda Container that uses the Aembit Lambda Extension to provided dynamic authentication to Snowflake.  The function runs a simple Python script that executes a Snowflake query that is pulled from the `SNOWFLAKE_QUERY` environment variable.  

## Usage
1. Ensure your [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) and [Aembit](https://registry.terraform.io/providers/Aembit/aembit/latest/docs) provider credentials are configured correctly
2. Configure required variables
3. Run `terraform init` and `terraform apply`
4. After the terraform apply completes, update the Callback URL in your Salesforce app to match the Callback URL field of the Aembit Credential Provider
5. Review ECS service logs for successful query output.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aembit"></a> [aembit](#requirement\_aembit) | ~> 1.25.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aembit"></a> [aembit](#provider\_aembit) | 1.24.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.18.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aembit-ecs"></a> [aembit-ecs](#module\_aembit-ecs) | Aembit/ecs/aembit | 1.22.1 |
| <a name="module_aembit_ecs_container"></a> [aembit\_ecs\_container](#module\_aembit\_ecs\_container) | ../../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aembit_agent_controller.ecs](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/agent_controller) | resource |
| [aembit_server_workload.salesforce](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/server_workload) | resource |
| [aembit_trust_provider.ecs](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/trust_provider) | resource |
| [aws_cloudwatch_log_group.salesforce_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_repository.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.salesforce_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.salesforce_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.iam_for_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.controller_all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.controller_http_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.controller_https_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [null_resource.build](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aembit_agent_log_level"></a> [aembit\_agent\_log\_level](#input\_aembit\_agent\_log\_level) | Log level of Aembit agent proxy Lambda extension. | `string` | `"info"` | no |
| <a name="input_aembit_tenant_id"></a> [aembit\_tenant\_id](#input\_aembit\_tenant\_id) | ID of Aembit tenant. | `string` | n/a | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | ID of AWS where Aembit edge components will be deployed. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where Aembit edge components will be deployed. | `string` | n/a | yes |
| <a name="input_salesforce_client_id"></a> [salesforce\_client\_id](#input\_salesforce\_client\_id) | Client ID of Salesforce Oauth app. | `string` | n/a | yes |
| <a name="input_salesforce_client_secret"></a> [salesforce\_client\_secret](#input\_salesforce\_client\_secret) | Client secret of Salesforce Oauth app. | `string` | n/a | yes |
| <a name="input_salesforce_host"></a> [salesforce\_host](#input\_salesforce\_host) | FQDN of Salesforce instance. | `string` | n/a | yes |
| <a name="input_salesforce_oauth_scopes"></a> [salesforce\_oauth\_scopes](#input\_salesforce\_oauth\_scopes) | Set of Salesforce Oauth scopes for Credential Provider. | `string` | `"full offline_access refresh_token openid"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where Aembit edge components will be deployed. | `set(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of AWS VPC where Aembit edge components will be deployed. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->