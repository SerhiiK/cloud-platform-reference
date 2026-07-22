# nvidia-drivers

Installs the proprietary NVIDIA GPU driver on **Ubuntu Server** (headless).

The role installs the DKMS build prerequisites, blacklists the open-source
`nouveau` driver, installs an NVIDIA driver (auto-detected or pinned), reboots
when required, and verifies the driver with `nvidia-smi`.

## Requirements

- Target: Ubuntu Server 22.04 (jammy) or 24.04 (noble).
- The host must have working `apt` access to Ubuntu's `restricted`/`multiverse`
  components (the `nvidia-driver-*` packages live there).
- Privilege escalation (`become: true`).

## Role variables

| Variable | Default | Description |
| --- | --- | --- |
| `nvidia_driver_package` | `nvidia-driver-580-server` | Package to install. `580` is the last branch supporting the Pascal GTX 1050 (through Oct 2028). Use `auto` to let `ubuntu-drivers` pick. |
| `nvidia_driver_use_server_branch` | `true` | Prefer the longer-lived `-server` branch when autodetecting. |
| `nvidia_driver_blacklist_nouveau` | `true` | Blacklist `nouveau` and rebuild initramfs. |
| `nvidia_driver_reboot` | `true` | Reboot automatically when required to activate the driver. |
| `nvidia_driver_reboot_timeout` | `600` | Seconds to wait for the host to return after reboot. |
| `nvidia_driver_verify` | `true` | Run `nvidia-smi` to confirm the driver loaded. |

## Example

```yaml
- name: homelab
  hosts: all
  become: true
  roles:
    - role: nvidia-drivers
      tags: [nvidia]

# Pin a specific driver, no automatic reboot:
    - role: nvidia-drivers
      vars:
        nvidia_driver_package: nvidia-driver-550-server
        nvidia_driver_reboot: false
```

## Notes

- A **reboot is required** the first time the driver (or the nouveau blacklist)
  is applied. With `nvidia_driver_reboot: false` the role reports that a reboot
  is pending and skips `nvidia-smi` verification.
- `-server` driver branches are recommended by NVIDIA/Canonical for headless and
  datacenter hosts.
