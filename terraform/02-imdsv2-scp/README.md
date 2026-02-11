# Phase 2 - SCP to Require IMDSv2

This phase deploys an AWS Organizations Service Control Policy (SCP) that **denies EC2 actions unless IMDSv2 is required**. The SCP is attached to an OU or the Organization root to enforce the guardrail at authorization time (preventive control).

Terraform also enables the SCP policy type for the Organization root (required before attaching SCPs).

## What the policy does

It denies:

- `ec2:RunInstances` when the request does not set `HttpTokens = required`
- `ec2:ModifyInstanceMetadataOptions` when attempting to set `HttpTokens` to anything other than `required`

Optionally, you can allowlist automation or break-glass principals to exempt them from the SCP.

## Files

- `main.tf` - SCP definition and attachment
- `variables.tf` - Inputs for policy name, target ID, allowlist
- `outputs.tf` - SCP and attachment IDs

## Inputs

- `policy_name` (string): Name of the SCP (default: `deny-ec2-imdsv1`)
- `target_id` (string): OU ID or root ID to attach the SCP
- `root_id` (string): Organization root ID used to enable SCP policy type
- `allowlisted_principal_arns` (list(string)): Optional list of principal ARNs exempt from the SCP

Tip: use the `ou_id` or `root_id` outputs from Phase 1 (`terraform/01-org-bootstrap`) as the `target_id`.

## Deploy

```bash
terraform init
terraform apply
```

## Validation (required proof)

### 1) Attempt to launch with IMDSv1 allowed (should be denied)

```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type t3.micro \
  --metadata-options HttpTokens=optional
```

Expected: `AccessDenied`.

### 2) Launch with IMDSv2 required (should be allowed)

```bash
aws ec2 run-instances \
  --image-id <ami-id> \
  --instance-type t3.micro \
  --metadata-options HttpTokens=required
```

Expected: request succeeds.

### 3) Attempt to modify metadata options to optional (should be denied)

```bash
aws ec2 modify-instance-metadata-options \
  --instance-id <instance-id> \
  --http-tokens optional
```

Expected: `AccessDenied`.

### 4) CloudTrail evidence

Check CloudTrail for denied events with error code `AccessDenied` for:

- `RunInstances`
- `ModifyInstanceMetadataOptions`

## Known limitations / edge cases

- SCPs do not apply to the management account by default. Attach to an OU that contains the member accounts in scope.
- The SCP denies when `HttpTokens` is not `required` or is omitted from the API request.
- Existing instances launched before the SCP was attached are not retroactively changed; they must be modified (which is then enforced).

## Tear down

```bash
terraform destroy
```
