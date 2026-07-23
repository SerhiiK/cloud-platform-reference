# Ansible — homelab provisioning

Ansible code for configuring homelab nodes. It installs:

- [`nvidia-drivers`](roles/nvidia-drivers/README.md) — a local role that installs
  the proprietary NVIDIA driver on Ubuntu Server.
- **Docker** — via the [`geerlingguy.docker`](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/docker/)
  role from Ansible Galaxy (installs Docker CE + the Compose plugin).

## Layout

```
ansible/
├── deployment.yaml            # main playbook
├── inventory.ini              # hosts (homelab)
├── requirements.yml           # Ansible Galaxy dependencies (Docker role)
├── roles/
│   └── nvidia-drivers/        # NVIDIA driver installation role (local)
├── .ansible-lint              # ansible-lint config
└── .yamllint                  # yamllint config
```

Inventory:

```ini
[homelab]
gpu-node ansible_host=192.168.0.102

[homelab:vars]
ansible_user=ubuntu
```

## Prerequisites

- Ansible on the control machine: `pip install ansible-core` (or `brew install ansible`).
- `sshpass` — required for password authentication (`--ask-pass`):
  - macOS: `brew install hudochenkov/sshpass/sshpass`
  - Ubuntu: `sudo apt install sshpass`
- Network access to the node over SSH (port 22).
- **Galaxy roles** — install the external dependencies once before running:
  ```bash
  ansible-galaxy install -r requirements.yml
  ```

## 1. Check connectivity to the machine

### ICMP ping (is the node alive on the network)

```bash
ping -c 4 192.168.0.102
```

### Ansible ping (checks SSH + authentication + Python on the node)

This is the main check — it confirms Ansible can actually manage the node, not
just that it responds on the network.

```bash
ansible -i inventory.ini homelab -m ping --ask-pass
```

Expected response:

```
gpu-node | SUCCESS => {
    "ansible_facts": {"discovered_interpreter_python": "/usr/bin/python3"},
    "changed": false,
    "ping": "pong"
}
```

> On the first connection SSH will ask you to confirm the host key. To skip that
> in automation: `export ANSIBLE_HOST_KEY_CHECKING=False` (fine for a homelab).

If the node uses an SSH key instead of a password, drop `--ask-pass`.

## 2. Run the role

Passwords are **not stored** in the repo — they are prompted at run time:

- `--ask-pass` (`-k`) — SSH password for the `ubuntu` user
- `--ask-become-pass` (`-K`) — sudo password (the role installs packages via `become`)

### Dry run before applying

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass --check --diff
```

### Actual run

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass
```

Run a single role by tag — `nvidia` or `docker`:

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass --tags nvidia
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass --tags docker
```

> ⚠️ The NVIDIA role will **reboot the node** when required to activate the driver
> (controlled by the `nvidia_driver_reboot` variable, `true` by default).

### What the playbook does

- **nvidia-drivers**: installs `nvidia-driver-580-server` (the last branch
  supporting Pascal / GTX 1050), blacklists `nouveau`, reboots if needed, and
  verifies with `nvidia-smi`. Details in
  [roles/nvidia-drivers/README.md](roles/nvidia-drivers/README.md).
- **geerlingguy.docker**: adds Docker's apt repo, installs Docker CE + the
  Compose plugin, and adds the connection user (`ansible_user`) to the `docker`
  group. Configured in `deployment.yaml`; full variable reference on
  [the role's Galaxy page](https://galaxy.ansible.com/ui/standalone/roles/geerlingguy/docker/).

> **Note on brand-new Ubuntu releases:** the Docker role derives the apt repo
> from the host's release codename. If Docker has not yet published packages for
> your codename (`apt` 404 on `download.docker.com`), pin the repo to the latest
> LTS codename, e.g. `-e docker_apt_release_channel=stable` and override the
> suite, or wait for Docker to publish it.

## 3. Verify the result

When the playbook finishes the NVIDIA role prints `nvidia-smi`. Manually on the node:

```bash
ssh ubuntu@192.168.0.102 nvidia-smi        # GPU driver
ssh ubuntu@192.168.0.102 docker run --rm hello-world   # Docker
```

> The user is added to the `docker` group during the run, but that only takes
> effect on the **next login** — reconnect (or `newgrp docker`) before running
> `docker` without sudo.

## Linting (locally)

CI (`.github/workflows/ansible-ci.yml`) runs this on every PR, but you can run it
locally too:

```bash
pip install ansible-lint yamllint
ansible-galaxy install -r requirements.yml   # needed for the syntax check to resolve the Docker role
yamllint .
ansible-lint
ansible-playbook --syntax-check -i inventory.ini deployment.yaml
```
