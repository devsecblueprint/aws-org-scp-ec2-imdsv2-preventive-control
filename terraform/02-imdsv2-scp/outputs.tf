output "scp_policy_id" {
  description = "ID of the SCP that enforces IMDSv2."
  value       = aws_organizations_policy.imdsv2_required.id
}

output "scp_policy_arn" {
  description = "ARN of the SCP that enforces IMDSv2."
  value       = aws_organizations_policy.imdsv2_required.arn
}

output "scp_attachment_id" {
  description = "ID of the policy attachment."
  value       = aws_organizations_policy_attachment.target.id
}
