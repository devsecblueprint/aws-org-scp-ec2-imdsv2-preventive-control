locals {
  org_root_id = (
    var.create_organization
    ? aws_organizations_organization.this[0].roots[0].id
    : data.aws_organizations_organization.existing[0].roots[0].id
  )
  org_id = (
    var.create_organization
    ? aws_organizations_organization.this[0].id
    : data.aws_organizations_organization.existing[0].id
  )
}