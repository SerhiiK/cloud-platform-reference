# Terraform + Terragrunt

This document captures the infrastructure-as-code approach for the platform
using Terraform for provisioning and Terragrunt for orchestration.

## Why this approach

- Terraform provides the IaC tool and ecosystem.
- Terragrunt standardizes remote state, DRY configuration, and dependencies.
- The combo supports multi-account and multi-env workflows cleanly.

## Structure (high level)

- Terraform modules define reusable infrastructure building blocks.
- Terragrunt layers configure those modules per account/environment.
- Dependencies define ordering (for example: org → network → EKS).

## Workflow

1) Configure backend and provider settings in Terragrunt.
2) Apply foundational layers (org/landing zone, shared services).
3) Apply environment stacks (networking, EKS, platform add-ons).

## Conventions

- Keep modules small and purpose-driven.
- Centralize shared variables in Terragrunt root config.
- Use separate state for each layer to reduce blast radius.

## Related docs

- Multi-account landing zone ADR
- GitOps approach ADR
