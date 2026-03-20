# AWS Organization SCP – EC2 IMDSv2 Preventive Control

## Project Overview

This project demonstrates how to implement a **preventive security control** in AWS using **Service Control Policies (SCPs)** within AWS Organizations.

You will build an organizational guardrail that prevents EC2 instances from being launched or modified unless **Instance Metadata Service v2 (IMDSv2)** is required. This control is enforced at the organization level, before the EC2 API action executes, regardless of IAM permissions.

This project is part of the **DevSecOps Blueprint (DSB)** learning community and is designed to teach real-world cloud governance.

## Why This Project Exists

By default, Amazon EC2 allows **IMDSv1**, which has been exploited in real-world attacks (e.g., SSRF vulnerabilities) to steal credentials from running instances.

Relying on documentation, best-practice guidance, or IAM permissions alone is not sufficient because human error still happens. This project applies a **preventive control** that makes the misconfiguration impossible. If someone attempts to launch an EC2 instance without IMDSv2 required, or modify an existing instance to allow IMDSv1, the request is denied by AWS itself.

## Learning Objectives

By completing this project, you will be able to:

1. **Understand preventive controls** — explain the difference between preventive, detective, and corrective controls, and why prevention is preferred for high-impact misconfigurations.
2. **Understand AWS Organizations for governance** — explain why SCPs require AWS Organizations, and the role of the management account and Organizational Units (OUs).
3. **Understand the risk of IMDSv1** — describe the difference between IMDSv1 and IMDSv2, and why `HttpTokens = required` is a security best practice.
4. **Build an organizational guardrail** — write an SCP that denies non-compliant EC2 actions and understand why SCPs override IAM permissions.
5. **Use Terraform for preventive security** — create and manage SCPs using Infrastructure as Code and apply guardrails safely at the OU level.
6. **Validate preventive controls** — prove that non-compliant EC2 actions are denied, compliant actions are allowed, and use CloudTrail as evidence of enforcement.

## Project Structure

```
terraform/
├── 01-org-bootstrap/     # Organization and OU setup
├── 02-imdsv2-scp/        # SCP policy creation and attachment
└── 03-ec2-instance/      # Demo EC2 instance for validation
```

### Phase 1 – Organization Bootstrap (`terraform/01-org-bootstrap`)

Sets up the AWS Organizations foundation. This phase:

- Optionally creates a new AWS Organization (set `create_organization = false` if your account is already in one)
- Creates an Organizational Unit (`dsb-labs` by default) for scoping the SCP
- Optionally creates a sandbox member account for safe testing

Key variables:

| Variable | Default | Description |
|---|---|---|
| `create_organization` | `false` | Set to `true` only if you need to create a new org |
| `ou_name` | `dsb-labs` | Name of the OU for lab enforcement scope |
| `create_sandbox_account` | `true` | Whether to create a sandbox member account |
| `sandbox_account_email` | — | Required if creating a sandbox account |

### Phase 2 – IMDSv2 Preventive SCP (`terraform/02-imdsv2-scp`)

Creates and attaches an SCP that denies EC2 actions unless IMDSv2 is required. The policy covers two actions:

- `ec2:RunInstances` — denied when `MetadataHttpTokens` is not `required`
- `ec2:ModifyInstanceMetadataOptions` — denied when `HttpTokens` is not `required`

Supports an optional allowlist of IAM principal ARNs for break-glass or automation exemptions.

Key variables:

| Variable | Default | Description |
|---|---|---|
| `target_id` | — | OU or root ID to attach the SCP to |
| `root_id` | — | Organization root ID |
| `allowlisted_principal_arns` | `[]` | IAM ARNs exempt from the SCP |

### Phase 3 – Demo EC2 Instance (`terraform/03-ec2-instance`)

Deploys a basic EC2 instance running Apache (httpd) on Amazon Linux 2023. Use this to validate SCP enforcement.

- The instance uses `http_tokens = "required"` (IMDSv2 enforced) by default
- To test the SCP denial, change `http_tokens` to `"optional"` and apply from a member account inside the target OU
- Includes a security group allowing HTTP inbound

Key variables:

| Variable | Default | Description |
|---|---|---|
| `instance_type` | `t3.micro` | EC2 instance type |
| `allowed_cidr` | `0.0.0.0/0` | CIDR allowed for HTTP access |

## Prerequisites

- **AWS account** with an IAM user or role that has administrator permissions (never use root)
- **AWS Organization** — either existing or created via Phase 1
- **Terraform** >= 1.5
- **AWS CLI** v2

## Usage

Run each phase in order:

```bash
# Phase 1 — Bootstrap the org and OU
cd terraform/01-org-bootstrap
terraform init
terraform apply

# Phase 2 — Create and attach the SCP
cd ../02-imdsv2-scp
terraform init
terraform apply -var="target_id=<OU_ID>" -var="root_id=<ROOT_ID>"

# Phase 3 — Launch a demo EC2 instance (from a member account)
cd ../03-ec2-instance
terraform init
terraform apply
```

> Use the `ou_id` and `root_id` outputs from Phase 1 as inputs to Phase 2.

## Validating the SCP

1. From a **member account** inside the target OU, try launching an EC2 instance with `http_tokens = "optional"` — it should be denied.
2. Launch with `http_tokens = "required"` — it should succeed.
3. Check **CloudTrail** for the denied API calls as evidence of enforcement.

> [!NOTE]
> SCPs do not apply to the management account. You must test from a member account.

## Safety Notice

SCPs are organization-level guardrails and can block actions across many accounts. Always test in non-production accounts first, review policy logic carefully, and roll out gradually.

## Disclaimer

This project is for learning and reference purposes. Review and adapt all security controls to your organization's risk profile and compliance requirements before production use.
