# If the org already exists, look it up via data source.
data "aws_organizations_organization" "existing" {
  count = var.create_organization ? 0 : 1
}