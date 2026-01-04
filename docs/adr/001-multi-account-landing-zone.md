# ADR 001: Multi-account Landing Zone

## Status
Accepted

## Context
The platform must separate concerns between shared services and workloads, enforce guardrails,
and enable least-privilege access across environments (dev/prod).

## Decision
Adopt a multi-account AWS Organization with at least three accounts:
- shared-services: central tooling (ECR, logging, GitOps tooling)
- dev: non-production workloads
- prod: production workloads

A dedicated security account may be added later for log archive and audit.

## Consequences
- Stronger isolation and blast-radius reduction.
- Requires cross-account IAM and centralized logging setup.
- Adds initial complexity for account vending and baseline policies.

