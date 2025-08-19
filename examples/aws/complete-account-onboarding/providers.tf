provider "aembit" {
  tenant = var.aembit_tenant_id
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
}
