.PHONY: lint fmt kind-cluster

lint:
	./scripts/lint.sh

fmt:
	./scripts/fmt.sh

kind-cluster:
	./scripts/kind_cluster.sh
