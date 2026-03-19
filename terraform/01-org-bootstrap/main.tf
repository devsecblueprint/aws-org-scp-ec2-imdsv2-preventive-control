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

# Create an AWS Organization only if one doesn't already exist.
resource "aws_organizations_organization" "this" {
  count       = var.create_organization ? 1 : 0
  feature_set = "ALL"
}

# Create an OU under the Organization root for lab enforcement scope.
resource "aws_organizations_organizational_unit" "dsb_labs" {
  name      = var.ou_name
  parent_id = local.org_root_id
}

resource "aws_organizations_account" "sandbox" {
  count = var.create_sandbox_account ? 1 : 0

  name      = var.sandbox_account_name
  email     = var.sandbox_account_email
  parent_id = aws_organizations_organizational_unit.dsb_labs.id

  close_on_deletion = true
}
