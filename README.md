# cloud-platform-reference

A DevOps reference/portfolio platform, built incrementally. This repository
currently contains the **infrastructure provisioning** layer — Ansible code that
prepares homelab nodes (GPU drivers, container runtime) for running workloads.

> Status: early stage. Only the components documented below actually exist in
> the repo today; more layers (IaC, Kubernetes, GitOps, observability) are
> planned but not yet present.

## Repository layout

```
.
├── ansible/                    # node provisioning (see ansible/README.md)
│   ├── deployment.yaml         #   main playbook
│   ├── inventory.ini           #   hosts
│   ├── requirements.yml        #   Ansible Galaxy dependencies
│   └── roles/
│       └── nvidia-drivers/     #   local role: proprietary NVIDIA driver
└── .github/workflows/
    └── ansible-ci.yml          # lint + syntax check on PRs touching ansible/
```

## What's provisioned

The Ansible playbook (`ansible/deployment.yaml`) configures Ubuntu Server nodes:

| Component | Source | Purpose |
| --- | --- | --- |
| **nvidia-drivers** | local role | Installs the proprietary NVIDIA driver (`nvidia-driver-580-server`, supports Pascal / GTX 1050), blacklists `nouveau`, reboots and verifies with `nvidia-smi`. |
| **Docker** | [`geerlingguy.docker`](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/docker/) (Galaxy) | Installs Docker CE + the Compose plugin and adds the connection user to the `docker` group. |

Full setup, connectivity checks, and run instructions live in
**[ansible/README.md](ansible/README.md)**.

### Quick start

```bash
cd ansible
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass
```

## CI

Every pull request that touches `ansible/**` runs
[`ansible-ci`](.github/workflows/ansible-ci.yml): `yamllint`, `ansible-lint`
(profile: `production`), and a playbook syntax check.
