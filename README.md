# HomeCloud

> [!IMPORTANT]
> This project is designed to manage my cloud-like setup at home, which is specific
> to my use cases and hardware, so it might not be directly useful to you.
> For a ready-to-use solution, please refer to my [homelab project](https://github.com/khuedoan/homelab).

## Installation

### Proxmox Virtual Environment

Download Proxmox VE ISO:

<https://www.proxmox.com/en/downloads>

Write it to a USB drive:

```sh
lsblk
sudo dd bs=1M if=proxmox-ve_${VERSION}.iso of=/dev/${USB_DRIVE}
```

Then boot to the USB drive and install Proxmox.

- Hostname: `proxmox`
- Root password: save it to a password manager

### Prerequisites for automation

There are some initial setup for Proxmox and OpenTofu state backend:

```sh
cd global/init
make
```

Then connect it to Tailscale:

```sh
ssh root@${PROXMOX_IP}
tailscale up
```

Follow the link to authenticate and optionally disable key expiry in Tailscale admin console.
From now on, Proxmox is accessible from the Tailnet via <https://proxmox:8006>.

## Environments

- `global`: manage users, groups, etc.
- `staging`: staging environment
- `production`: production environment

To plan/apply an environment, e.g. staging:

```sh
make plan env=staging
make apply env=staging
```

## Tips and tricks

OpenTofu (Terraform) PostgreSQL backend debugging example:

```sh
# Connect to staging state storage
$ psql --user=tfstate --host=proxmox tfstate_staging
# The table is keyed by the workspace name.
# If workspaces are not in use, the name default is used.
tfstate_staging=> SELECT * FROM terraform_remote_state.states;
```

Update encrypted variables in Ansible Vault:

```sh
ansible-vault edit example/path/to/vault.yaml
```
