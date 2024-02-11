# HomeCloud

> [!IMPORTANT]
> This project is designed to manage my cloud-like setup at home, which is specific
> to my use cases and hardware, so it might not be directly useful to you.
> For a ready-to-use solution, please refer to my [homelab project](https://github.com/khuedoan/homelab).

The cloud is "just" somebody else's computer, with a hypervisor, management APIs,
and managed services like IAM, RDS, K8s, etc. This project attempts to create a
cloud-like experience using commodity hardware.

While my primary self-hosting platform is still [my homelab](https://github.com/khuedoan/homelab)
with high availability in mind, in this project I only run a single node for the
hypervisor and intentionally ignore distributed system problems 🙈 (for a secondary
system running non-critical services, the costs aren't justified, both in terms
of money and complexity).
Of course, it won't match the capabilities of a real cloud provider, lacking features
such as redundancy, multiple regions, health checks, etc.

A few key components are necessary:

- Proxmox provides the hypervisor, a web console, and management APIs (which can
  be automated with OpenTofu - a Terraform fork).
- Managed services are immutable VM/LXC images built with NixOS.

I use this project for three main purposes:

- Offsite backup: the Proxmox node is located at my parents' house in a different
  region of my country, with a separate disk that I mount to a VM running Minio.
- External monitoring system for my main monitoring system: [quis custodiet ipsos custodes?](https://en.wikipedia.org/wiki/Quis_custodiet_ipsos_custodes%3F)
- A flexible playground: because my main Kubernetes cluster runs on bare-metal nodes,
  it lacks flexibility for quick experimentation with things like PXE boot, BSD distros, etc.
  With a hypervisor, I can easily spin up a VM for rapid testing.

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
make init
```

Then connect it to Tailscale:

```sh
ssh root@${PROXMOX_IP}
tailscale up --accept-dns=false
```

Follow the link to authenticate and optionally disable key expiry in Tailscale admin console.
From now on, Proxmox is accessible from the Tailnet via <https://proxmox:8006>.

## Project structure

- `global`: manage users, groups, etc.
- `staging`: staging environment
- `production`: production environment

To apply an environment, e.g. staging:

```sh
make staging
```

To build a pre-defined VM/LXC image, e.g. `uptime-kuma`:

```sh
cd global/images
nix build --no-link --print-out-paths .#uptime-kuma
```

Copy the output path and put it in `global/images.tf`, then run `make global`.
The images are fully producible and hermetic and always produce the same hash
if given the same inputs.

This project embraces the idea of immutable infrastructure, so I don't upgrade
existing VMs/CTs. Instead, I build a new image, feed it to Proxmox, and replace
the VM/CT. Only data mounted to a separate disk is kept (if you're familiar with
Docker, the mental model is similar to `docker run --volume`). Another benefit
of this approach is that it stops me from constantly reinstalling VMs/CTs if I
feel like they're "dirty", since everything is always in a clean state, and if
not, it will be wiped in the next image update.

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
