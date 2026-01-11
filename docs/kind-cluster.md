# Kind Cluster

This is the quickest way to get a local Kubernetes cluster running so you can
iterate on the platform without touching real cloud resources. It’s intentionally
simple: one command to create, one command to delete.

## Prerequisites

- `kind` installed and on your `PATH`

## Create a local cluster

Default cluster name is `local-dev-cluster`. If you’re just getting started,
stick with the default and move on. If you juggle multiple clusters, a custom
name keeps things tidy.

```bash
make kind-cluster
```

To use a custom name:

```bash
CLUSTER_NAME=my-cluster make kind-cluster
```

Or pass the name directly:

```bash
./scripts/kind_cluster.sh my-cluster
```

## Delete a local cluster

When you’re done experimenting or need a clean slate, delete the cluster. This
removes the local Docker containers created by kind.

```bash
make kind-delete
```

Or:

```bash
./scripts/kind_delete.sh my-cluster
```
