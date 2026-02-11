terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {}

# Validation that can reference multiple variables.
check "sandbox_email_required" {
  assert {
    condition = (
      var.create_sandbox_account == false ||
      length(trim(var.sandbox_account_email, " ")) > 0
    )
    error_message = "sandbox_account_email is required when create_sandbox_account=true."
  }
}

# Create an AWS Organization if one doesn't already exist.
# Note: If the account is already in an Organization, this resource will error if applied.
# For a learning repo, we assume the learner is starting from a standalone account.
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

# Create an OU under the Organization root for lab enforcement scope.
resource "aws_organizations_organizational_unit" "dsb_labs" {
  name      = var.ou_name
  parent_id = aws_organizations_organization.this.roots[0].id
}
resource "aws_organizations_account" "sandbox" {
  count = var.create_sandbox_account ? 1 : 0

  name      = var.sandbox_account_name
  email     = var.sandbox_account_email
  parent_id = aws_organizations_organizational_unit.dsb_labs.id

  # Best practice: do not automatically grant the management account access to the member account's
  # billing role. Leave it default unless your org needs it.
  # role_name can be set if you want a predictable default role created in the member account.
}
