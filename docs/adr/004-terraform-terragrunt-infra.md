# ADR 004: Terraform + Terragrunt for Infrastructure

## Status
Accepted

## Context
We need repeatable, auditable infrastructure provisioning across multiple AWS
accounts and environments. The platform also needs clear separation between
infrastructure layers (org/landing zone, networking, EKS, shared services) and
a way to manage shared configuration with minimal duplication.

## Decision
Adopt Terraform as the IaC engine and Terragrunt as the orchestration layer.
Use Terragrunt to manage environment layering, remote state, and dependency
ordering across accounts and regions.

## Consequences
- Standardized IaC workflow across the repo.
- Clear separation of shared vs environment-specific configuration.
- Additional tooling to learn and maintain (Terragrunt wrappers).
