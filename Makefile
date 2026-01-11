.PHONY: lint fmt kind-cluster kind-delete argocd-autopilot kind-argocd

fmt:
	./scripts/fmt.sh

kind-cluster:
	./scripts/kind_cluster.sh

kind-delete:
	./scripts/kind_delete.sh

argocd-autopilot:
	./scripts/argocd_autopilot.sh

kind-argocd: kind-cluster argocd-autopilot
