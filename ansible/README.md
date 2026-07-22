# Ansible — homelab provisioning

Ansible code for configuring homelab nodes. It currently contains the
[`nvidia-drivers`](roles/nvidia-drivers/README.md) role, which installs the
proprietary NVIDIA driver on Ubuntu Server.

## Layout

```
ansible/
├── deployment.yaml            # main playbook
├── inventory.ini              # hosts (homelab)
├── roles/
│   └── nvidia-drivers/        # NVIDIA driver installation role
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

Only tasks tagged `nvidia`:

```bash
ansible-playbook -i inventory.ini deployment.yaml --ask-pass --ask-become-pass --tags nvidia
```

> ⚠️ The role will **reboot the node** when required to activate the driver
> (controlled by the `nvidia_driver_reboot` variable, `true` by default).

### What the role does

Installs `nvidia-driver-580-server` (the last branch supporting Pascal / GTX 1050),
blacklists `nouveau`, reboots the node if needed, and verifies the result with
`nvidia-smi`. Variables and details are in
[roles/nvidia-drivers/README.md](roles/nvidia-drivers/README.md).

## 3. Verify the result

When the playbook finishes it prints `nvidia-smi`. Manually on the node:

```bash
ssh ubuntu@192.168.0.102 nvidia-smi
```

## Linting (locally)

CI (`.github/workflows/ansible-ci.yml`) runs this on every PR, but you can run it
locally too:

```bash
pip install ansible-lint yamllint
yamllint .
ansible-lint
ansible-playbook --syntax-check -i inventory.ini deployment.yaml
```
