# ADR 003: GitOps Approach

## Status
Accepted

## Context
The platform requires consistent, auditable deployments across environments and clusters.

## Decision
Adopt Argo CD Autopilot to bootstrap and manage GitOps structure and applications.
Use ApplicationSets for multi-env and multi-cluster delivery.

## Consequences
- Standardized repo layout and automated bootstrap.
- Clear separation between platform and app delivery.
- Requires operational knowledge for recovery and drift handling.

