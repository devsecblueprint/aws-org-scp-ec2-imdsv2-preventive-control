# Phase 1 – Organization Bootstrap

This step prepares your AWS environment so that **Service Control Policies (SCPs)** can be used safely.

Before you can enforce preventive controls, AWS requires that you operate inside an **AWS Organization**.  
This phase establishes that foundation.

---

## What This Step Does

Running this Terraform configuration will:

1. Create an **AWS Organization** (if one does not already exist)
2. Enable **ALL organization features** (required for SCPs)
3. Create an **Organizational Unit (OU)** named `dsb-labs`

This OU will later be used as a **safe scope** to attach and test the SCP.

---

## Why This Step Exists

Service Control Policies:

- **cannot exist** in a standalone AWS account
- are enforced at the **organization level**
- can affect all accounts in scope

To avoid accidental lockouts:

- SCPs should **not** be attached directly to the management account
- An OU provides a controlled boundary for enforcement

This step ensures we apply governance **safely and intentionally**.

---

## Important Safety Notes (Read Carefully)

- This Terraform code must be run from the **management account**
- Terraform must be executed using an **IAM administrator identity**
- **Do NOT run this using the root user**

> If your account is already part of an AWS Organization, Terraform will reuse it and will NOT recreate the organization.

---

## Prerequisites

Before running this step, ensure:

- You have completed **Phase 0**
- You are authenticated as an IAM administrator
- AWS CLI is configured correctly

Verify your identity:

```bash
aws sts get-caller-identity
