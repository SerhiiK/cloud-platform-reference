Backlog (GitHub Issues)
M0 — Repo & GitOps bootstrap
1) Repo skeleton + стандарти

Labels: area/ci prio/P0 size/S
Description: Структура mono-repo: infra/ (terragrunt), platform/ (charts/manifests), apps/ (demo), docs/. CODEOWNERS, conventional commits, pre-commit.
Acceptance criteria:

Є README з high-level архітектурою і діаграмою (хоч Mermaid).

Є docs/adr/ мінімум 3 ADR: multi-account, observability stack, GitOps approach.

make lint / make fmt проходять.

Є шаблони PR/Issue.

2) Argo CD Autopilot: bootstrap GitOps repo

Labels: area/gitops prio/P0 size/M
Description: Підняти Argo CD та “opinionated” структуру репо через Autopilot (bootstrapping + базові apps).
Argo-CD Autopilot
+2
Argo-CD Autopilot
+2

Acceptance criteria:

argocd-autopilot repo bootstrap ... успішно створює структуру та ставить Argo CD.

Є базовий “platform app” (наприклад platform/) і “apps app” (apps/).

Описаний recovery сценарій (як підняти ArgoCD з repo з нуля).

3) Argo CD ApplicationSet для multi-env / multi-cluster (навіть якщо Autopilot)

Labels: area/gitops prio/P1 size/M
Description: ApplicationSet для генерації apps на dev/stage/prod (clusters/environments).
Argo CD

Acceptance criteria:

Є мінімум 2 генератори (наприклад git + list/cluster).

Деплой 1 demo-app в 3 енви одним шаблоном.

Є секція “Security considerations” (про права dev-ів).
Argo CD

M1 — Multi-account Landing Zone (must-have для “$7k+”)
4) AWS Organizations: account structure + baseline IAM

Labels: area/landing-zone prio/P0 size/L
Description: Описати/створити 3 акаунти: shared-services, dev, prod (можеш додати security як 4-й). Terraform/Tofu або manual, але з IaC-drift-free підходом.
Acceptance criteria:

Документована структура OUs/Accounts.

Є terraform apply (або хоча б reproducible steps) для створення org/account baseline.

Є “break-glass” процедура (екстрений доступ) в docs.

5) SCP guardrails (мінімум 3 SCP)

Labels: area/landing-zone area/security prio/P0 size/M
Description: Реальні SCP-и: (1) deny leaving org, (2) deny non-approved regions, (3) enforce tagging / deny disabling CloudTrail/Config (обережно з deny).
docs.aws.amazon.com
+1

Acceptance criteria:

SCP-и застосовані до OU, задокументовано “why” і “blast radius”.

Є приклади тестів: “цю дію блокує” vs “цю пропускає”.

Є “how to debug SCP denies”.

6) (Optional, але дуже жирно) AWS Control Tower landing zone

Labels: area/landing-zone prio/P1 size/L
Description: Якщо потягнеш — Control Tower як готовий landing zone, guardrails + account vending.
docs.aws.amazon.com
+1

Acceptance criteria:

Landing zone активна, OU/Accounts під governance.

В docs — порівняння “DIY landing zone vs Control Tower”.

M2 — Networking & Shared Services
7) Hub-and-spoke networking (VPC per account + shared services)

Labels: area/network prio/P0 size/L
Description: VPC у кожному env-акаунті + shared services VPC. Опційно TGW, або простіше: VPC peering (для демо).
Acceptance criteria:

Є схема CIDR, subnets, routing, endpoints.

З dev EKS можна достукатися до shared сервісів (наприклад private ECR endpoint / logs endpoint).

В docs: trade-offs TGW vs peering.

8) Centralized audit/log baseline (CloudTrail/Config) + “log archive”

Labels: area/landing-zone area/security prio/P0 size/M
Description: Базовий audit: CloudTrail, Config, central S3 (log archive).
Acceptance criteria:

Є централізований bucket + політики доступу.

Події з member accounts реально потрапляють в archive.

В docs: retention + cost notes.

M3 — EKS per env + Karpenter + addons
9) EKS dev/stage/prod (Terragrunt) + стандартні addons

Labels: area/eks prio/P0 size/L
Description: EKS у 3 env, baseline addons: VPC CNI, CoreDNS, kube-proxy, metrics-server, external-dns/ESO за потреби.
Acceptance criteria:

terragrunt run-all apply піднімає dev → stage → prod (або окремими командами).

kubectl get nodes -A показує очікувані ноди.

Є runbook “create new env”.

10) Karpenter: NodePools (spot/on-demand) + disruption budgets + consolidation

Labels: area/karpenter prio/P0 size/L
Description: 2 NodePool: on-demand для критичних, spot для burst. Disruption budgets, consolidationPolicy, expireAfter.
karpenter.sh
+1

Acceptance criteria:

Є nodepools з різними constraints (instance families, capacity-type).

Є disruption budgets з “business hours” логікою (хоч schedule) або хоча б з обмеженням %.
karpenter.sh
+1

Демонстрація: scale-up (pending pods → nodes), scale-down (consolidation).

Docs: “how to debug provisioning failures”.

11) Pod Identity (не тільки IRSA) для workload access

Labels: area/eks area/security prio/P1 size/M
Description: Використати EKS Pod Identity для доступу подів до AWS сервісів.
docs.aws.amazon.com

Acceptance criteria:

Є приклад app, що читає S3/SSM через Pod Identity.

Документовано вимоги до SDK версій.
docs.aws.amazon.com

(Бонус) приклад cross-account доступу через pod identity associations.
docs.aws.amazon.com

M4 — Security & Supply chain (сильно піднімає рівень)
12) GitHub Actions: OIDC → AWS (no static keys)

Labels: area/ci area/security prio/P0 size/M
Description: Terraform план/аплай + build/push images через OIDC federation.
GitHub
+2
Amazon Web Services, Inc.
+2

Acceptance criteria:

Workflow має permissions: id-token: write.

Немає AWS access keys у secrets.

Роль в AWS має trust policy на token.actions.githubusercontent.com.
GitHub

Є приклад least-privilege policy для terraform plan/apply.

13) Image signing: Cosign keyless + policy enforcement в кластері

Labels: area/security prio/P0 size/L
Description: Підписувати образи (keyless) і заборонити непідписані через Kyverno verifyImages.
release-1-13-0.kyverno.io
+3
Sigstore
+3
Sigstore
+3

Acceptance criteria:

Pipeline підписує image digest (cosign sign <image@sha256:...>).
Sigstore

Kyverno policy блокує деплой непідписаного образу, дозволяє підписаний.
Kyverno
+1

В docs: як це працює + як ротувати/оновлювати правила.

14) Kyverno policy pack (мінімум 8 правил)

Labels: area/security prio/P1 size/M
Description: Окрім verifyImages: runAsNonRoot, readOnlyRootFilesystem, no hostPath, ресурси (requests/limits), заборона privileged, required labels/annotations, allowed registries, network policies baseline.
Acceptance criteria:

8+ політик у policies/ + тест-кейси (bad manifests).

Є CI job, що проганяє політики на прикладах (kyverno CLI або dry-run).

M5 — Observability (OTEL + Victoria Stack)
15) Встановити VictoriaMetrics + Grafana datasource

Labels: area/observability prio/P0 size/M
Description: VictoriaMetrics як metrics backend + Grafana datasource (або Prometheus-compat URL).
docs.victoriametrics.com
+1

Acceptance criteria:

Grafana бачить datasource і будує dashboard (CPU/mem/pod restarts).

Є записаний “quickstart” як підключити datasource.
docs.victoriametrics.com

16) Встановити VictoriaLogs + Grafana plugin

Labels: area/observability prio/P0 size/M
Description: VictoriaLogs + Grafana datasource plugin.
Grafana Labs
+2
docs.victoriametrics.com
+2

Acceptance criteria:

Плагін встановлений (helm або grafana plugins) і datasource працює.

Є dashboard з logs + фільтри (namespace/app).

Документовано як деплоїти плагін (особливо якщо self-hosted Grafana).
GitHub

17) Встановити VictoriaTraces + OTLP ingestion

Labels: area/observability prio/P1 size/M
Description: VictoriaTraces як traces backend, прийом OTLP.
docs.victoriametrics.com
+1

Acceptance criteria:

Traces інжестяться через /insert/opentelemetry/v1/traces.
docs.victoriametrics.com

Є demo-app, що шле traces (OTLP exporter).

Є базовий trace view/use-case (latency, error path).

18) OpenTelemetry Collector via Helm (pipelines: metrics/logs/traces)

Labels: area/observability prio/P0 size/L
Description: OTel Collector Helm chart як DaemonSet або Deployment.
OpenTelemetry
+2
OpenTelemetry
+2

Acceptance criteria:

Є 3 pipeline-и (metrics/logs/traces) і експортери в Victoria* endpoints.

Kubernetes events збираються як logs (k8sobjects receiver).
OpenTelemetry

Документовано values.yaml і схема потоків даних.

19) OTEL → Victoria endpoints (правильні URL)

Labels: area/observability prio/P0 size/M
Description: Правильно прокинути endpoint-и:

VM: /opentelemetry/v1/metrics
docs.victoriametrics.com
+1

VL: /insert/opentelemetry/v1/logs
docs.victoriametrics.com

VT: /insert/opentelemetry/v1/traces
docs.victoriametrics.com

Acceptance criteria:

Є e2e demo (одна кнопка): генерує метрики+логи+трейси, і ти це бачиш у Grafana.

У docs: таблиця endpoints + приклади env vars OTEL_EXPORTER_* (як стандартизувати).
OpenTelemetry

20) SLO dashboards + алерти (мінімум 2 SLO)

Labels: area/observability prio/P1 size/M
Description: Два SLO (availability + latency) для demo-app; burn-rate alerts.
Acceptance criteria:

Є SLO дашборд в Grafana + 2 алерти.

Є “game day” скрипт: викликає деградацію і алерт спрацьовує.

M6 — SRE Delivery: Progressive delivery + Autoscaling
21) Argo Rollouts: canary + AnalysisTemplate (auto rollback)

Labels: area/delivery prio/P1 size/L
Description: Canary rollout з аналізом метрик (наприклад error rate / latency) і автоскат.
Argo Rollouts
+2
Argo Rollouts
+2

Acceptance criteria:

Є Rollout ресурс (не Deployment) + steps.

Є AnalysisTemplate, що читає метрики та вирішує success/fail.
Argo Rollouts

Демо: “bad version” → rollback автоматично.

22) KEDA: event-driven autoscaling (SQS) + TriggerAuthentication

Labels: area/autoscaling prio/P1 size/L
Description: KEDA ScaledObject на SQS, з нуля до N подів.
KEDA
+2
KEDA
+2

Acceptance criteria:

ScaledObject працює: 0 → N при появі повідомлень, N → 0 коли черга пуста.

KEDA auth зроблено без секретів (через IAM/POD identity де можливо).

Docs: параметри queueLength/activationQueueLength.
KEDA

23) Platform “golden path”: Backstage templates + TechDocs (optional, але дуже $7k+)

Labels: area/platform prio/P2 size/L
Description: Backstage як portal: template “new service” (repo + helm chart + Argo app), TechDocs для docs-as-code.
backstage.io
+1

Acceptance criteria:

Є 1 working template: створює skeleton сервісу + додає в catalog.

TechDocs будується і відкривається зі сторінки сервісу.

24) Runbooks + incident-style docs (SRE відчуття)

Labels: area/sre prio/P1 size/M
Description: Runbooks для топ-5 сценаріїв: Karpenter не провіженить, Argo sync fail, OTEL pipeline broken, Kyverno блокує, KEDA не скейлить.
Acceptance criteria:

5 runbooks з “symptoms → checks → fix”.

В кожному runbook є 3-5 конкретних команд kubectl/argocd/grafana.

25) “Evidence pack” для інтерв’ю (дуже важливо)

Labels: area/docs prio/P0 size/S
Description: Окремий docs/interview/ з:

архітектура, trade-offs, cost notes

security story (OIDC, SCP, signing, policies)

reliability story (SLO, rollout, autoscaling)
Acceptance criteria:

Є 1 сторінка “tell me about your platform” (2–3 хв pitch).

Є скріншоти: Argo, Grafana dashboards, Rollouts, Karpenter nodes.

