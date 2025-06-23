# Lambda Container Using Aembit to Access Snowflake
Configuration in this directory creates an Aembit Access Policy and AWS Lambda Container that uses the Aembit Lambda Extension to provided dynamic authentication to Snowflake.  The function runs a simple Python script that executes a Snowflake query that is pulled from the `SNOWFLAKE_QUERY` environment variable.  

## Usage
1. Ensure your [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration) and [Aembit](https://registry.terraform.io/providers/Aembit/aembit/latest/docs) provider credentials are configured correctly
2. Configure required variables
3. Run `terraform init` and `terraform apply`
4. After the terraform apply completes, execute the query in the `snowflake_alter_user_commands` output against your Snowflake instance to configure the Snowflake user to allow dynamic authentication with a JWT signed by an Aembit-managed key pair instead of a password.
5. Test the Lambda function for successful query output.

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

### <a name="module_aembit_lambda_container"></a> [aembit\_lambda\_container](#module\_aembit\_lambda\_container)

Source: ../../../

Version:

## Resources

The following resources are used by this module:

- [aembit_server_workload.snowflake](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/server_workload) (resource)
- [aws_cloudwatch_log_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_ecr_repository.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) (resource)
- [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_lambda_function.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) (resource)
- [aws_security_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_vpc_security_group_egress_rule.all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) (resource)
- [null_resource.build](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
- [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_aembit_agent_controller_url"></a> [aembit\_agent\_controller\_url](#input\_aembit\_agent\_controller\_url)

Description: FQDN of Aembit Agent Controller.

Type: `string`

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

### <a name="input_snowflake_username"></a> [snowflake\_username](#input\_snowflake\_username)

Description: Snowflake username for Lambda function authentication.

Type: `string`

### <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)

Description: List of subnet IDs where Aembit edge components will be deployed.

Type: `set(string)`

### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: ID of AWS VPC where Aembit edge components will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aembit_agent_log_level"></a> [aembit\_agent\_log\_level](#input\_aembit\_agent\_log\_level)

Description: Log level of Aembit agent proxy Lambda extension.

Type: `string`

Default: `"debug"`

### <a name="input_snowflake_database"></a> [snowflake\_database](#input\_snowflake\_database)

Description: Snowflake database for Lambda function to query.

Type: `string`

Default: `"SNOWFLAKE_SAMPLE_DATA"`

### <a name="input_snowflake_query"></a> [snowflake\_query](#input\_snowflake\_query)

Description: Snowflake query for Lambda function to run.

Type: `string`

Default: `"SELECT \"C_NAME\", \"C_ACCTBAL\" FROM CUSTOMER;"`

### <a name="input_snowflake_schema"></a> [snowflake\_schema](#input\_snowflake\_schema)

Description: Snowflake schema for Lambda function to query.

Type: `string`

Default: `"TPCH_SF1"`

### <a name="input_snowflake_warehouse"></a> [snowflake\_warehouse](#input\_snowflake\_warehouse)

Description: Snowflake warehouse for Lambda function to query.

Type: `string`

Default: `"COMPUTE_WH"`

## Outputs

The following outputs are exported:

### <a name="output_snowflake_alter_user_commands"></a> [snowflake\_alter\_user\_commands](#output\_snowflake\_alter\_user\_commands)

Description: Aembit resource id for Lambda client workload.
<!-- END_TF_DOCS -->