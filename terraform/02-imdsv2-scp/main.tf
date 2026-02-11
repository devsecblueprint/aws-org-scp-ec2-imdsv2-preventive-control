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

locals {
  has_allowlist = length(var.allowlisted_principal_arns) > 0

  allowlist_condition = local.has_allowlist ? {
    ArnNotLike = {
      "aws:PrincipalArn" = var.allowlisted_principal_arns
    }
  } : {}

  # RunInstances: deny if MetadataHttpTokens != required
  runinstances_condition = merge(
    local.allowlist_condition,
    {
      StringNotEquals = {
        "ec2:MetadataHttpTokens" = "required"
      }
    }
  )

  # ModifyInstanceMetadataOptions: deny if Attribute/HttpTokens != required
  # Null guard prevents denying requests where HttpTokens isn't being set.
  modify_condition = merge(
    local.allowlist_condition,
    {
      StringNotEquals = {
        "ec2:Attribute/HttpTokens" = "required"
      }
      Null = {
        "ec2:Attribute/HttpTokens" = false
      }
    }
  )

  policy_document = {
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRunInstancesWithoutIMDSv2"
        Effect   = "Deny"
        Action   = "ec2:RunInstances"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = local.runinstances_condition
      },
      {
        Sid      = "DenyModifyInstanceMetadataOptionsWithoutIMDSv2"
        Effect   = "Deny"
        Action   = "ec2:ModifyInstanceMetadataOptions"
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = local.modify_condition
      }
    ]
  }
}

resource "aws_organizations_policy" "imdsv2_required" {
  name        = var.policy_name
  description = "Prevent EC2 instances from launching or being modified unless IMDSv2 is required (HttpTokens=required)."
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode(local.policy_document)
}

resource "aws_organizations_policy_attachment" "target" {
  policy_id = aws_organizations_policy.imdsv2_required.id
  target_id = var.target_id
}
