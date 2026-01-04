# Async Task Platform — Project Context

## Goal
Build a production-grade async task platform to demonstrate
Platform Engineering skills (EKS, GitOps, OTEL, Security).

## Product
Users submit tasks → tasks processed asynchronously → results returned.

Supported task types:
- Data processing
- Report generation
- Event handling

## Architecture
Frontend → API Gateway → Task Service → SQS → Worker → Result Service

## Platform Features
- Multi-account AWS (dev/prod/shared-services)
- GitOps (ArgoCD Autopilot)
- Autoscaling (KEDA + Karpenter)
- Observability (OTEL → VictoriaMetrics/Logs/Traces)
- Security (Cosign + Kyverno)
- Progressive delivery (Argo Rollouts)

## Demo Scenarios
1. Event-driven autoscaling (scale-to-zero)
2. Canary rollback on latency spike
3. Unsigned image denied by policy


