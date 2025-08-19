# Aembit Access Policies Terraform module
Terraform module for creating a set of Aembit Access Policies, Trust Providers, and Credential Providers for a Client Workload.

## Usage
```
module "access_policies" {
  source                      = "Aembit/access-policies/aembit"
  client_workload_identities = [
    {
      type  = "awsLambdaArn"
      value = "arn:aws:lambda:us-west-2:123456789012:function:lambda-function-name
    }
  ]
  access_policies = {
    aembit = {
      is_active = true
      server_workload_name = "aembit-abc123"
      credential_provider_name = "aembit"
    }
  }
  trust_providers = {
    aws_role = {
      type = "aws_role"
      aws_role = {
        account_id = "123456789012"
        role_arn   = "arn:aws:sts::123456789012:assumed-role/iam-role-name/lambda-function-name"
      }
    }
  }
  client_workload_name = "lambda-function-name"
  credential_providers = {
    aembit = {
      is_active = true
      type = "aembit_access_token"
      aembit_access_token = {
        lifetime = 900
        role_id = "6b78f5e9-ef4a-431b-9817-386221b0f6bd"
      }
    }
  }
}
```

## Client Workload Creation
By default this module will provision a new Client Workload in Aembit Cloud, which requires the `client_workload_identities` variable to be populated.  If you want to create Access Policies for a Client Workload that already exists, add `create_client_workloads = false` to configure the module to lookup an existing Client Workload based on the `client_workload_name` variable.

If your Client Workload is a Lambda Function that needs to be invoked with Aliases include the Alias arns in the `client_workload_identities` block

## Trust Provider Creation
By default this module will provision new Trust Providers in Aembit Cloud, which requires the `trust_providers` variable to be populated.  If you want to create Access Policies with a Trust Provider that already exists, add `create_trust_providers = false` to configure the module to lookup an existing Trust Provider based on the `trust_provider_name` variable.

## Credential Provider Creation
By default this module will provision new Credential Providers in Aembit Cloud, which requires the `credential_providers` variable to be populated.  If you want to create Access Policies with a Trust Provider that already exists, add `create_credential_providers = false` to configure the module to lookup an existing Credential Provider based on the `credential_provider_name` argument in the `access_policies` block.

## Examples
[AWS Quickstart](https://github.com/Aembit/terraform-aembit-access-policies/tree/main/examples/aws/quickstart)

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5)

- <a name="requirement_aembit"></a> [aembit](#requirement\_aembit) (>= 1.17.0)

## Providers

The following providers are used by this module:

- <a name="provider_aembit"></a> [aembit](#provider\_aembit) (>= 1.17.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aembit_access_policy.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/access_policy) (resource)
- [aembit_client_workload.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/client_workload) (resource)
- [aembit_credential_provider.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/credential_provider) (resource)
- [aembit_trust_provider.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/resources/trust_provider) (resource)
- [aembit_access_conditions.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/data-sources/access_conditions) (data source)
- [aembit_client_workloads.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/data-sources/client_workloads) (data source)
- [aembit_credential_providers.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/data-sources/credential_providers) (data source)
- [aembit_server_workloads.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/data-sources/server_workloads) (data source)
- [aembit_trust_providers.this](https://registry.terraform.io/providers/aembit/aembit/latest/docs/data-sources/trust_providers) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies)

Description: Map of access policy configuration objects to be created for the associated client workload.

is\_active: Boolean indicating if access policy is active in Aembit Cloud.  
server\_workload\_name: Name of Aembit server workload associated with this access policy.  
credential\_provider\_name: Name of Aembit credential provider to associate with this access policy.  
access\_condition\_names: Set of Aembit access condition names to associate with this access policy.

Type:

```hcl
map(object({
    is_active                = optional(bool, true)
    server_workload_name     = string
    credential_provider_name = string
    access_condition_names   = optional(set(string), [])
  }))
```

### <a name="input_client_workload_name"></a> [client\_workload\_name](#input\_client\_workload\_name)

Description: Name of client workload.  This will be used in the name of all Aembit resources for this client workload.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_client_workload_identities"></a> [client\_workload\_identities](#input\_client\_workload\_identities)

Description: Set of Client workload identity configuration objects.  If `create_client_workload = true` this variable is required.

Type:

```hcl
set(object({
    type  = string
    value = string
  }))
```

Default: `null`

### <a name="input_create_client_workload"></a> [create\_client\_workload](#input\_create\_client\_workload)

Description: Boolean indiciating if module should create a new client workload or use an existing one.  If this is `true` the `client_workload_identities variable is required. Defaults to true.`

Type: `bool`

Default: `true`

### <a name="input_create_credential_providers"></a> [create\_credential\_providers](#input\_create\_credential\_providers)

Description: Boolean indiciating if module should create a new credential provider or use an existing one.  If this is `true` the credential provider configurations will need to be provided. Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_create_trust_providers"></a> [create\_trust\_providers](#input\_create\_trust\_providers)

Description: Boolean indiciating if module should create a new trust provider or use an existing one.  If this is `true` the trust provider configurations will need to be provided. Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_credential_providers"></a> [credential\_providers](#input\_credential\_providers)

Description: Map of credential provider configuration objects for this module to create.  If this is not provided, no new credential providers will be added.

name: Name of credential provider  
is\_active: Boolean indicating if credential provider is active in Aembit Cloud.  
type: Type of credential provider.  Valid values are `aembit_access_token`, `api_key`, `aws_sts`, `snowflake_jwt`, or `username_password`.  
aembit\_access\_token: Configuration block for [Aembit Access Token credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--aembit_access_token).  This should only be provided if type is `aembit_access_token`.  
api\_key: Configuration block for [API Key credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--api_key).  This should only be provided if type is `api_key`.  
aws\_sts: Configuration block for [AWS STS credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--aws_sts).  This should only be provided if type is `aws_sts`.  
google\_workload\_identity: Configuration block for [Google Workload Identity credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--google_workload_identity).  This should only be provided if type is `google_workload_identity`.  
oauth\_authorization\_code: Configuration block for [Oauth Authorization Code credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--oauth_authorization_code).  This should only be provided if type is `oauth_authorization_code`.  
oauth\_client\_credentials: Configuration block for [Oauth Client Credentials credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--oauth_client_credentials).  This should only be provided if type is `oauth_client_credentials`.  
snowflake\_jwt: Configuration block for [Snowflake JWT credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--snowflake_jwt).  This should only be provided if type is `snowflake_jwt`.  
username\_password: Configuration block for [Username Password credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--username_password).  This should only be provided if type is `username_password`.  
vault\_client\_token: Configuration block for [Vault Client Token credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--vault_client_token).  This should only be provided if type is `vault_client_token`.

Type:

```hcl
map(object({
    is_active = optional(bool, true)
    type      = string
    aembit_access_token = optional(object({
      lifetime = number
      role_id  = string
    }), null)
    api_key = optional(object({
      api_key = string
    }), null)
    aws_sts = optional(object({
      role_arn = string
      lifetime = optional(string)
    }), null)
    google_workload_identity = optional(object({
      audience        = string
      service_account = string
      lifetime        = optional(string)
    }), null)
    oauth_authorization_code = optional(object({
      client_id               = string
      client_secret           = string
      oauth_authorization_url = string
      oauth_discovery_url     = string
      oauth_token_url         = string
      scopes                  = string
      custom_parameters       = optional(set(map(string)))
      is_pkce_required        = optional(bool)
      lifetime                = optional(number)
    }), null)
    oauth_client_credentials = optional(object({
      client_id         = string
      client_secret     = string
      credential_style  = string
      scopes            = string
      token_url         = string
      custom_parameters = optional(set(map(string)))
    }), null)
    snowflake_jwt = optional(object({
      account_id = string
      username   = string
    }), null)
    username_password = optional(object({
      password = string
      username = string
    }), null)
    vault_client_token = optional(object({
      lifetime         = string
      subject          = string
      subject_type     = string
      vault_host       = string
      vault_path       = string
      vault_port       = number
      vault_tls        = bool
      custom_claims    = optional(set(map(string)))
      vault_forwarding = optional(string)
      vault_namespace  = optional(string)
      vault_role       = optional(string)
    }), null)
  }))
```

Default: `null`

### <a name="input_is_active"></a> [is\_active](#input\_is\_active)

Description: Boolean indicating if workload and associated resources are active in Aembit Cloud.  Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags to apply to Aembit resources

Type: `map(string)`

Default: `null`

### <a name="input_trust_provider_name"></a> [trust\_provider\_name](#input\_trust\_provider\_name)

Description: Name of trust provider to use for access policy.  If this is not provided a new trust provider will be created and additional variables will be required.

Type: `string`

Default: `""`

### <a name="input_trust_providers"></a> [trust\_providers](#input\_trust\_providers)

Description: Map of trust provider configuration objects for this module to create.  If this is not provided, no new trust providers will be added.

name: Name of trust provider  
is\_active: Boolean indicating if trust provider is active in Aembit Cloud.  
type: Type of trust provider.  Valid values are `aws_metadata`, `aws_role`, `azure_metadata`, `gcp_identity`, `github_action`, `gitlab_job`, `kerberos`, `kubernetes_service_account`, or `terraform_workspace`.  
aws\_metadata: Configuration block for [AWS Metadata trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--aws_metadata).  This should only be provided if type is `aws_metadata`.  
aws\_role: Configuration block for [AWS IAM Role trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--aws_role).  This should only be provided if type is `aws_role`.  
azure\_metadata: Configuration block for [Azure Metadata trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--azure_metadata).  This should only be provided if type is `azure_metadata`.  
gcp\_identity: Configuration block for [GCP Identity trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--gcp_identity).  This should only be provided if type is `gcp_identity`.  
github\_action: Configuration block for [Githb Action trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--github_action).  This should only be provided if type is `github_action`.  
gitlab\_job: Configuration block for [Gitlab Job trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#gitlab_job-1).  This should only be provided if type is `gitlab_job`.  
kerberos: Configuration block for [Kerberos trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--kerberos).  This should only be provided if type is `kerberos`.  
kubernetes\_service\_account: Configuration block for [Kubernetes Service Account trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--kubernetes_service_account).  This should only be provided if type is `kubernetes_service_account`.  
terraform\_workspace: Configuration block for [Terraform Workspace trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--terraform_workspace).  This should only be provided if type is `terraform_workspace`.

Type:

```hcl
map(object({
    is_active = optional(bool, true)
    type      = string
    aws_metadata = optional(object({
      account_id                 = optional(string)
      architectecture            = optional(string)
      availability_zone          = optional(string)
      billing_products           = optional(string)
      certificate                = optional(string)
      image_id                   = optional(string)
      instance_id                = optional(string)
      instance_type              = optional(string)
      kernel_id                  = optional(string)
      marketplace_products_codes = optional(string)
      pending_time               = optional(string)
      private_ip                 = optional(string)
      ramdisk_id                 = optional(string)
      region                     = optional(string)
      version                    = optional(string)
    }), null)
    aws_role = optional(object({
      account_id   = optional(string)
      assumed_role = optional(string)
      role_arn     = optional(string)
      username     = optional(string)
    }), null)
    azure_metadata = optional(object({
      sku             = optional(string)
      subscription_id = optional(string)
      vm_id           = optional(string)
    }), null)
    gcp_identity = optional(object({
      email = optional(string)
    }), null)
    github_action = optional(object({
      actor      = optional(string)
      repository = optional(string)
      workflow   = optional(string)
    }), null)
    gitlab_job = optional(object({
      namespace_path  = optional(string)
      namespace_paths = optional(set(string))
      oidc_endpoint   = optional(string)
      project_path    = optional(string)
      project_paths   = optional(set(string))
      ref_path        = optional(string)
      ref_paths       = optional(set(string))
      subject         = optional(string)
      subjects        = optional(set(string))
    }), null)
    kerberos = optional(object({
      agent_controller_ids = set(string)
      principal            = optional(string)
      realm                = optional(string)
      source_ip            = optional(string)
    }), null)
    kubernetes_service_account = optional(object({
      issuer               = optional(string)
      namespace            = optional(string)
      oidc_endpoint        = optional(string)
      pod_name             = optional(string)
      public_key           = optional(string)
      service_account_name = optional(string)
      subject              = optional(string)
    }), null)
    terraform_workspace = optional(object({
      organization_id = optional(string)
      project_id      = optional(string)
      workspace_id    = optional(string)
    }), null)
  }))
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_access_policies"></a> [access\_policies](#output\_access\_policies)

Description: List of Aembit resource ids for created access policies.

### <a name="output_client_workload_id"></a> [client\_workload\_id](#output\_client\_workload\_id)

Description: Aembit resource id for Lambda client workload.

### <a name="output_credential_providers"></a> [credential\_providers](#output\_credential\_providers)

Description: List of credential providers created by module.

### <a name="output_trust_provider_ids"></a> [trust\_provider\_ids](#output\_trust\_provider\_ids)

Description: List of Aembit resource ids for Lambda trust providers.
<!-- END_TF_DOCS -->