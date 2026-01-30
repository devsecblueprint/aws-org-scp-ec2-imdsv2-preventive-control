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
