# ADR 002: Observability Stack

## Status
Accepted

## Context
We need full metrics, logs, and traces with OpenTelemetry ingestion and Grafana dashboards.
The stack should be Kubernetes-friendly and cost-effective.

## Decision
Use the VictoriaMetrics stack:
- VictoriaMetrics for metrics
- VictoriaLogs for logs
- VictoriaTraces for traces

OpenTelemetry Collector provides a single ingestion layer and exports to Victoria endpoints.
Grafana is the primary UI.

## Consequences
- Unified OTEL pipeline simplifies agent deployment.
- Victoria stack is efficient for cost/scale.
- Requires careful endpoint configuration and version compatibility.

