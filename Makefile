.PHONY: lint fmt kind-cluster

fmt:
	./scripts/fmt.sh

kind-cluster:
	./scripts/kind_cluster.sh
