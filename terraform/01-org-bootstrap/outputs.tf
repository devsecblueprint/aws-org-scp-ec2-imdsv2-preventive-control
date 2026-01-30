output "organization_id" {
  description = "AWS Organization ID."
  value       = aws_organizations_organization.this.id
}

output "root_id" {
  description = "Organization Root ID."
  value       = aws_organizations_organization.this.roots[0].id
}

output "ou_id" {
  description = "OU ID for the lab scope (attach SCPs here)."
  value       = aws_organizations_organizational_unit.dsb_labs.id
}
