output "snowflake_alter_user_commands" {
  description = "Aembit resource id for Lambda client workload."
  value       = [for v in module.aembit_lambda_container.credential_providers : v["alter_user_command"]]
}
