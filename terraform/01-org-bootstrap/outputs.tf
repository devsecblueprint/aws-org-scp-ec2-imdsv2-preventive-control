output "organization_id" {
  description = "AWS Organization ID."
  value       = local.org_id
}

output "root_id" {
  description = "Organization Root ID."
  value       = local.org_root_id
}

output "ou_id" {
  description = "OU ID for the lab scope (attach SCPs here)."
  value       = aws_organizations_organizational_unit.dsb_labs.id
}
