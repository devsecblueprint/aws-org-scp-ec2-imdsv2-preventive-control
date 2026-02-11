# AWS Organization SCP – EC2 IMDSv2 Preventive Control

## Project Overview

This project demonstrates how to implement a **preventive security control** in AWS using **AWS Organizations Service Control Policies (SCPs)**.

You will build an **organizational guardrail** that **prevents EC2 instances from being launched or modified unless Instance Metadata Service v2 (IMDSv2) is required**.

This control is enforced:

- **Before** the EC2 API action executes
- At the **AWS Organization level**
- Regardless of IAM permissions (including administrators)

This project is part of the **DevSecOps Blueprint (DSB)** learning community and is designed to teach **real-world cloud governance**, not just Terraform syntax.

---

## Why This Project Exists

By default, Amazon EC2 allows **IMDSv1**, which has been abused in real-world attacks (for example, SSRF vulnerabilities) to steal credentials from running instances.

Relying on:

- documentation,
- best-practice guidance,
- or IAM permissions

is **not sufficient**, because human error still happens.

This project applies a **preventive control** that makes the misconfiguration **impossible**.

If someone attempts to:

- launch an EC2 instance without IMDSv2 required, or
- modify an existing instance to allow IMDSv1,

the request is **denied by AWS itself**.

No alerts.  
No remediation.  
No exceptions.

---

## Learning Objectives

By completing this project, you will be able to:

1. **Understand preventive controls**
   - Explain the difference between preventive, detective, and corrective controls
   - Explain why prevention is preferred for high-impact misconfigurations

2. **Understand AWS Organizations for governance**
   - Explain why SCPs require AWS Organizations
   - Understand the role of the management account and OUs

3. **Understand the risk of IMDSv1**
   - Explain what IMDS is
   - Describe the difference between IMDSv1 and IMDSv2
   - Explain why `HttpTokens = required` is a security best practice

4. **Build an organizational guardrail**
   - Write an SCP that denies non-compliant EC2 actions
   - Understand why SCPs override IAM permissions

5. **Use Terraform for preventive security**
   - Create and manage SCPs using Infrastructure as Code
   - Apply guardrails safely at the OU level

6. **Validate preventive controls**
   - Prove that non-compliant EC2 actions are denied
   - Prove that compliant actions are allowed
   - Use CloudTrail as evidence of enforcement

---

## What You Will Build (Definition of Done)

You will build a **preventive organizational guardrail** that:

- Denies `ec2:RunInstances` when `HttpTokens` is not set to `required`
- Denies `ec2:ModifyInstanceMetadataOptions` when attempting to allow IMDSv1
- Is enforced **before IAM policies**
- Applies consistently across all accounts in scope

### You are done when

- Launching EC2 with `HttpTokens = optional` is **denied**
- Launching EC2 with `HttpTokens = required` is **allowed**
- Modifying an instance to allow IMDSv1 is **denied**
- CloudTrail shows the denied API calls
- The SCP is fully managed using Terraform

---

## Project Phases

### Phase 1 - Organization bootstrap

Creates the AWS Organization and an OU (`dsb-labs`). Optionally creates a sandbox member account.

Path: `terraform/01-org-bootstrap`

### Phase 2 - IMDSv2 preventive SCP

Creates and attaches an SCP that denies EC2 actions unless IMDSv2 is required. Attach it to the OU or root.

Path: `terraform/02-imdsv2-scp`

## Core Concepts (Quick Primer)

### AWS Organizations

Provides centralized governance across multiple AWS accounts.  
**SCPs only work inside AWS Organizations.**

### Organizational Units (OU)

Logical containers used to **scope policies safely**.  
In this lab, SCPs are applied to an OU—not the management account.

### Service Control Policies (SCP)

Organization-level guardrails that:

- Do **not** grant permissions
- Only **restrict** what IAM can do
- Cannot be overridden

### Preventive vs Detective Controls

- **Preventive**: block bad actions before they happen (this project)
- **Detective**: detect issues after they happen (e.g., logs, alerts)

---

## Prerequisites & Assumptions

Before starting, you must have:

### 1. AWS Account

- An existing AWS account
- Root user secured with MFA
- Root user **not used** for this lab

### 2. IAM Administrator Identity

- An IAM user or role with administrator permissions
- Used to run Terraform and AWS CLI
- Permissions to manage AWS Organizations and SCPs

> Terraform must always be run using this IAM identity — **never root**.

---

### 3. AWS Organization

- If your account is not part of an Organization, Terraform will create one
- Your existing AWS account becomes the **management account**

---

### 4. Organizational Unit Safety Model

- Terraform will create an OU named `dsb-labs`
- SCPs are attached to the OU, **not** directly to the management account

This prevents accidental lockouts.

---

### 5. Tools Required

You must have installed:

- Terraform ≥ 1.5
- AWS CLI v2
- Git (recommended)
