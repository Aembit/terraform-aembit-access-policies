variable "access_policies" {
  type = map(object({
    is_active                = optional(bool, true)
    server_workload_id       = optional(string)
    server_workload_name     = optional(string)
    credential_provider_name = optional(string)
    credential_providers = optional(set(object({
      credential_provider_name = string
      mapping_type             = string
      access_key_id            = optional(string)
      account_name             = optional(string)
      header_name              = optional(string)
      header_value             = optional(string)
      httpbody_field_path      = optional(string)
      httpbody_field_value     = optional(string)
    })))
    access_condition_names = optional(set(string), [])
  }))
  description = <<-EOT
    Map of access policy configuration objects to be created for the associated client workload.

    is_active: Boolean indicating if access policy is active in Aembit Cloud.
    server_workload_name: Name of Aembit server workload associated with this access policy.
    credential_provider_name: Name of Aembit credential provider to associate with this access policy (singular). Use this for single credential provider policies.
    credential_providers: Set of credential provider objects for multi-credential policies. Only `aws_sts` and `snowflake_jwt` credential provider types currently support multiple credential providers. Each object requires `credential_provider_name` and `mapping_type`, with optional `access_key_id`, `account_name`, `header_name`, `header_value`, `httpbody_field_path`, and `httpbody_field_value`.
    access_condition_names: Set of Aembit access condition names to associate with this access policy.
  EOT
  validation {
    condition = alltrue([
      for k, v in var.access_policies :
      (v.credential_provider_name != null) != (v.credential_providers != null)
    ])
    error_message = "Each access policy must specify exactly one of `credential_provider_name` (singular) or `credential_providers` (plural). You must provide one, but not both."
  }
}

variable "client_workload_identifiers" {
  type = set(object({
    type  = string
    value = string
  }))
  description = "Set of Client workload identity configuration objects.  If `create_client_workload = true` this variable is required."
  default     = null
}

variable "client_workload_name" {
  type        = string
  description = "Name of client workload.  This will be used in the name of all Aembit resources for this client workload."
}

variable "create_client_workload" {
  type        = bool
  description = "Boolean indicating if module should create a new client workload or use an existing one.  If this is `true`, the `client_workload_identifiers` variable is required. Defaults to true."
  default     = true
}

variable "create_credential_providers" {
  type        = bool
  description = "Boolean indicating if module should create a new credential provider or use an existing one.  If this is `true`, the credential provider configurations will need to be provided. Defaults to true."
  default     = true
}

variable "create_trust_providers" {
  type        = bool
  description = "Boolean indicating if module should create a new trust provider or use an existing one.  If this is `true`, the trust provider configurations will need to be provided. Defaults to true."
  default     = true
}

variable "credential_providers" {
  type = map(object({
    is_active = optional(bool, true)
    type      = string
    aembit_access_token = optional(object({
      lifetime = number
      role_id  = string
    }), null)
    api_key = optional(object({
      api_key = string
    }), null)
    aws_secrets_manager_value = optional(object({
      credential_provider_integration_id = string
      secret_arn                         = string
      private_network_access             = optional(bool)
      secret_key_1                       = optional(string)
      secret_key_2                       = optional(string)
    }), null)
    aws_sts = optional(object({
      role_arn = string
      lifetime = optional(number)
    }), null)
    azure_entra_workload_identity = optional(object({
      audience     = string
      azure_tenant = string
      client_id    = string
      scope        = string
      subject      = string
    }), null)
    azure_key_vault_value = optional(object({
      credential_provider_integration_id = string
      secret_name_1                      = string
      secret_name_2                      = optional(string)
      private_network_access             = optional(bool)
    }), null)
    google_workload_identity = optional(object({
      audience        = string
      service_account = string
      lifetime        = optional(number)
    }), null)
    jwt_svid_token = optional(object({
      algorithm_type      = string
      audience            = string
      lifetime_in_minutes = number
      subject             = string
      subject_type        = string
      custom_claims       = set(map(string))
    }), null)
    managed_gitlab_account = optional(object({
      access_level                       = number
      credential_provider_integration_id = string
      group_ids                          = set(string)
      lifetime_in_hours                  = number
      project_ids                        = set(string)
      scope                              = string
      service_account_username           = optional(string)
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
      oauth_introspection_url = optional(string)
    }), null)
    oauth_client_credentials = optional(object({
      client_id         = string
      client_secret     = string
      credential_style  = string
      scopes            = string
      token_url         = string
      custom_parameters = optional(set(map(string)))
    }), null)
    oidc_id_token = optional(object({
      algorithm_type      = string
      audience            = string
      lifetime_in_minutes = number
      subject             = string
      subject_type        = string
      custom_claims       = optional(set(map(string)))
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
      lifetime                     = number
      subject                      = string
      subject_type                 = string
      vault_host                   = string
      vault_path                   = string
      vault_port                   = number
      vault_tls                    = bool
      custom_claims                = optional(set(map(string)))
      vault_forwarding             = optional(string)
      vault_namespace              = optional(string)
      vault_private_network_access = optional(bool)
      vault_role                   = optional(string)
    }), null)
  }))
  # NOTE: sensitive is intentionally disabled. While this variable can contain secrets
  # (api_key, client_secret, password), marking it sensitive causes all downstream
  # outputs to become sensitive, reducing usability. See commit e15de41.
  description = <<-EOT
    Map of credential provider configuration objects for this module to create.  If this is not provided, no new credential providers will be added.

    name: Name of credential provider
    is_active: Boolean indicating if credential provider is active in Aembit Cloud.
    type: Type of credential provider.  Valid values are `aembit_access_token`, `api_key`, `aws_secrets_manager_value`, `aws_sts`, `azure_entra_workload_identity`, `azure_key_vault_value`, `google_workload_identity`, `jwt_svid_token`, `managed_gitlab_account`, `oauth_authorization_code`, `oauth_client_credentials`, `oidc_id_token`, `snowflake_jwt`, `username_password`, or `vault_client_token`.
    aembit_access_token: Configuration block for [Aembit Access Token credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--aembit_access_token).  This should only be provided if type is `aembit_access_token`.
    api_key: Configuration block for [API Key credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--api_key).  This should only be provided if type is `api_key`.
    aws_secrets_manager_value: Configuration block for [AWS Secrets Manager Value credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--aws_secrets_manager_value).  This should only be provided if type is `aws_secrets_manager_value`.
    aws_sts: Configuration block for [AWS STS credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--aws_sts).  This should only be provided if type is `aws_sts`.
    azure_entra_workload_identity: Configuration block for [Azure Entra Workload Identity Federation credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nested-schema-for-azure_entra_workload_identity).  This should only be provided if type is `azure_entra_workload_identity`.
    azure_key_vault_value: Configuration block for [Azure Key Vault Value credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--azure_key_vault_value).  This should only be provided if type is `azure_key_vault_value`.
    google_workload_identity: Configuration block for [Google Workload Identity credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--google_workload_identity).  This should only be provided if type is `google_workload_identity`.
    jwt_svid_token: Configuration block for [JWT SVID TOKEN credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nested-schema-for-jwt_svid_token).  This should only be provided if type is `jwt_svid_token`.
    managed_gitlab_account: Configuration block for [Managed Gitlab Account credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nested-schema-for-managed_gitlab_account).  This should only be provided if type is `managed_gitlab_account`.
    oauth_authorization_code: Configuration block for [Oauth Authorization Code credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--oauth_authorization_code).  This should only be provided if type is `oauth_authorization_code`.
    oauth_client_credentials: Configuration block for [Oauth Client Credentials credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--oauth_client_credentials).  This should only be provided if type is `oauth_client_credentials`.
    oidc_id_token: Configuration block for [OIDC ID TOKEN credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nested-schema-for-oidc_id_token).  This should only be provided if type is `oidc_id_token`.
    snowflake_jwt: Configuration block for [Snowflake JWT credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--snowflake_jwt).  This should only be provided if type is `snowflake_jwt`.
    username_password: Configuration block for [Username Password credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--username_password).  This should only be provided if type is `username_password`.
    vault_client_token: Configuration block for [Vault Client Token credential provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/credential_provider#nestedatt--vault_client_token).  This should only be provided if type is `vault_client_token`.
  EOT
  validation {
    condition     = alltrue([for o in var.credential_providers : contains(["aembit_access_token", "api_key", "aws_secrets_manager_value", "aws_sts", "azure_entra_workload_identity", "azure_key_vault_value", "google_workload_identity", "jwt_svid_token", "managed_gitlab_account", "oauth_authorization_code", "oauth_client_credentials", "oidc_id_token", "snowflake_jwt", "username_password", "vault_client_token"], o.type)])
    error_message = "All types must be one of `aembit_access_token`, `api_key`, `aws_secrets_manager_value`, `aws_sts`, `azure_entra_workload_identity`, `azure_key_vault_value`, `google_workload_identity`, `jwt_svid_token`, `managed_gitlab_account`, `oauth_authorization_code`, `oauth_client_credentials`, `oidc_id_token`, `snowflake_jwt`, `username_password`, or `vault_client_token`!"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "aembit_access_token" ? o.aembit_access_token != null : true])
    error_message = "`aembit_access_token` is required if `type` is `aembit_access_token`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "api_key" ? o.api_key != null : true])
    error_message = "`api_key` is required if `type` is `api_key`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "aws_secrets_manager_value" ? o.aws_secrets_manager_value != null : true])
    error_message = "`aws_secrets_manager_value` is required if `type` is `aws_secrets_manager_value`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "aws_sts" ? o.aws_sts != null : true])
    error_message = "`aws_sts` is required if `type` is `aws_sts`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "azure_entra_workload_identity" ? o.azure_entra_workload_identity != null : true])
    error_message = "`azure_entra_workload_identity` is required if `type` is `azure_entra_workload_identity`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "azure_key_vault_value" ? o.azure_key_vault_value != null : true])
    error_message = "`azure_key_vault_value` is required if `type` is `azure_key_vault_value`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "google_workload_identity" ? o.google_workload_identity != null : true])
    error_message = "`google_workload_identity` is required if `type` is `google_workload_identity`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "jwt_svid_token" ? o.jwt_svid_token != null : true])
    error_message = "`jwt_svid_token` is required if `type` is `jwt_svid_token`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "managed_gitlab_account" ? o.managed_gitlab_account != null : true])
    error_message = "`managed_gitlab_account` is required if `type` is `managed_gitlab_account`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "oauth_authorization_code" ? o.oauth_authorization_code != null : true])
    error_message = "`oauth_authorization_code` is required if `type` is `oauth_authorization_code`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "oauth_client_credentials" ? o.oauth_client_credentials != null : true])
    error_message = "`oauth_client_credentials` is required if `type` is `oauth_client_credentials`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "oidc_id_token" ? o.oidc_id_token != null : true])
    error_message = "`oidc_id_token` is required if `type` is `oidc_id_token`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "snowflake_jwt" ? o.snowflake_jwt != null : true])
    error_message = "`snowflake_jwt` is required if `type` is `snowflake_jwt`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "username_password" ? o.username_password != null : true])
    error_message = "`username_password` is required if `type` is `username_password`"
  }
  validation {
    condition     = alltrue([for o in var.credential_providers : o.type == "vault_client_token" ? o.vault_client_token != null : true])
    error_message = "`vault_client_token` is required if `type` is `vault_client_token`"
  }
  default = null
}

variable "is_active" {
  type        = bool
  description = "Boolean indicating if workload and associated resources are active in Aembit Cloud.  Defaults to true."
  default     = true
}

variable "standalone_certificate_authority" {
  type        = string
  description = "Standalone certificate authority for the client workload. Only applicable when `create_client_workload = true`."
  default     = null
}

variable "trust_provider_name" {
  type        = string
  description = "Name of trust provider to use for access policy.  If this is not provided a new trust provider will be created and additional variables will be required."
  default     = ""
}

variable "trust_providers" {
  type = map(object({
    is_active = optional(bool, true)
    type      = string
    aws_metadata = optional(object({
      account_id                = optional(string)
      account_ids               = optional(set(string))
      architecture              = optional(string)
      availability_zone         = optional(string)
      availability_zones        = optional(set(string))
      billing_products          = optional(string)
      certificate               = optional(string)
      image_id                  = optional(string)
      instance_id               = optional(string)
      instance_ids              = optional(set(string))
      instance_type             = optional(string)
      instance_types            = optional(set(string))
      kernel_id                 = optional(string)
      marketplace_product_codes = optional(string)
      pending_time              = optional(string)
      private_ip                = optional(string)
      ramdisk_id                = optional(string)
      region                    = optional(string)
      regions                   = optional(set(string))
      version                   = optional(string)
    }), null)
    aws_role = optional(object({
      account_id    = optional(string)
      account_ids   = optional(set(string))
      assumed_role  = optional(string)
      assumed_roles = optional(set(string))
      role_arn      = optional(string)
      role_arns     = optional(set(string))
      username      = optional(string)
      usernames     = optional(set(string))
    }), null)
    azure_metadata = optional(object({
      sku              = optional(string)
      skus             = optional(set(string))
      subscription_id  = optional(string)
      subscription_ids = optional(set(string))
      vm_id            = optional(string)
      vm_ids           = optional(set(string))
    }), null)
    certificate_signed_attestation = optional(object({}), null)
    gcp_identity = optional(object({
      email  = optional(string)
      emails = optional(set(string))
    }), null)
    github_action = optional(object({
      actor         = optional(string)
      actors        = optional(set(string))
      oidc_endpoint = optional(string)
      repositories  = optional(set(string))
      repository    = optional(string)
      workflow      = optional(string)
      workflows     = optional(set(string))
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
      principals           = optional(set(string))
      realm_domain         = optional(string)
      realms_domains       = optional(set(string))
      source_ip            = optional(string)
      source_ips           = optional(set(string))
    }), null)
    kubernetes_service_account = optional(object({
      issuer                = optional(string)
      issuers               = optional(set(string))
      jwks                  = optional(string)
      namespace             = optional(string)
      namespaces            = optional(set(string))
      oidc_endpoint         = optional(string)
      pod_name              = optional(string)
      pod_names             = optional(set(string))
      public_key            = optional(string)
      service_account_name  = optional(string)
      service_account_names = optional(set(string))
      subject               = optional(string)
      subjects              = optional(set(string))
    }), null)
    oidc_id_token = optional(object({
      audience      = optional(string)
      audiences     = optional(set(string))
      issuer        = optional(string)
      issuers       = optional(set(string))
      jwks          = optional(string)
      oidc_endpoint = optional(string)
      public_key    = optional(string)
      subject       = optional(string)
      subjects      = optional(set(string))
    }), null)
    terraform_workspace = optional(object({
      organization_id  = optional(string)
      organization_ids = optional(set(string))
      project_id       = optional(string)
      project_ids      = optional(set(string))
      workspace_id     = optional(string)
      workspace_ids    = optional(set(string))
    }), null)
  }))
  description = <<-EOT
    Map of trust provider configuration objects for this module to create.  If this is not provided, no new trust providers will be added.

    name: Name of trust provider
    is_active: Boolean indicating if trust provider is active in Aembit Cloud.
    type: Type of trust provider.  Valid values are `aws_metadata`, `aws_role`, `azure_metadata`, `certificate_signed_attestation`, `gcp_identity`, `github_action`, `gitlab_job`, `kerberos`, `kubernetes_service_account`, `oidc_id_token`, or `terraform_workspace`.
    aws_metadata: Configuration block for [AWS Metadata trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--aws_metadata).  This should only be provided if type is `aws_metadata`.
    aws_role: Configuration block for [AWS IAM Role trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--aws_role).  This should only be provided if type is `aws_role`.
    azure_metadata: Configuration block for [Azure Metadata trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--azure_metadata).  This should only be provided if type is `azure_metadata`.
    certificate_signed_attestation: Configuration block for [Certificate Signed Attestation trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--certificate_signed_attestation).  This should only be provided if type is `certificate_signed_attestation`.
    gcp_identity: Configuration block for [GCP Identity trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--gcp_identity).  This should only be provided if type is `gcp_identity`.
    github_action: Configuration block for [GitHub Action trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--github_action).  This should only be provided if type is `github_action`.
    gitlab_job: Configuration block for [Gitlab Job trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#gitlab_job-1).  This should only be provided if type is `gitlab_job`.
    kerberos: Configuration block for [Kerberos trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--kerberos).  This should only be provided if type is `kerberos`.
    kubernetes_service_account: Configuration block for [Kubernetes Service Account trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--kubernetes_service_account).  This should only be provided if type is `kubernetes_service_account`.
    oidc_id_token: Configuration block for [OIDC ID Token trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nested-schema-for-oidc_id_token).  This should only be provided if type is `oidc_id_token`.
    terraform_workspace: Configuration block for [Terraform Workspace trust provider](https://registry.terraform.io/providers/Aembit/aembit/latest/docs/resources/trust_provider#nestedatt--terraform_workspace).  This should only be provided if type is `terraform_workspace`.
  EOT
  validation {
    condition     = alltrue([for o in var.trust_providers : contains(["aws_metadata", "aws_role", "azure_metadata", "certificate_signed_attestation", "gcp_identity", "github_action", "gitlab_job", "kerberos", "kubernetes_service_account", "oidc_id_token", "terraform_workspace"], o.type)])
    error_message = "All types must be one of `aws_metadata`, `aws_role`, `azure_metadata`, `certificate_signed_attestation`, `gcp_identity`, `github_action`, `gitlab_job`, `kerberos`, `kubernetes_service_account`, `oidc_id_token`, or `terraform_workspace`!"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "aws_metadata" ? o.aws_metadata != null : true])
    error_message = "`aws_metadata` is required if `type` is `aws_metadata`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "aws_role" ? o.aws_role != null : true])
    error_message = "`aws_role` is required if `type` is `aws_role`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "azure_metadata" ? o.azure_metadata != null : true])
    error_message = "`azure_metadata` is required if `type` is `azure_metadata`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "certificate_signed_attestation" ? o.certificate_signed_attestation != null : true])
    error_message = "`certificate_signed_attestation` is required if `type` is `certificate_signed_attestation`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "gcp_identity" ? o.gcp_identity != null : true])
    error_message = "`gcp_identity` is required if `type` is `gcp_identity`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "github_action" ? o.github_action != null : true])
    error_message = "`github_action` is required if `type` is `github_action`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "gitlab_job" ? o.gitlab_job != null : true])
    error_message = "`gitlab_job` is required if `type` is `gitlab_job`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "kerberos" ? o.kerberos != null : true])
    error_message = "`kerberos` is required if `type` is `kerberos`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "kubernetes_service_account" ? o.kubernetes_service_account != null : true])
    error_message = "`kubernetes_service_account` is required if `type` is `kubernetes_service_account`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "oidc_id_token" ? o.oidc_id_token != null : true])
    error_message = "`oidc_id_token` is required if `type` is `oidc_id_token`"
  }
  validation {
    condition     = alltrue([for o in var.trust_providers : o.type == "terraform_workspace" ? o.terraform_workspace != null : true])
    error_message = "`terraform_workspace` is required if `type` is `terraform_workspace`"
  }
  default = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Aembit resources"
  default     = null
}