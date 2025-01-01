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

- Incus provides the hypervisor, a web console, and management APIs (which can
  be automated with OpenTofu - a Terraform fork).
- Managed services are immutable VM/LXC images built with NixOS.

I use this project for three main purposes:

- Offsite backup: the Incus node is located at my parents' house in a different
  region of my country, with a separate disk that I mount to a VM running Minio.
- External monitoring system for my main monitoring system: [quis custodiet ipsos custodes?](https://en.wikipedia.org/wiki/Quis_custodiet_ipsos_custodes%3F)
- A flexible playground: because my main Kubernetes cluster runs on bare-metal nodes,
  it lacks flexibility for quick experimentation with things like PXE boot, BSD distros, etc.
  With a hypervisor, I can easily spin up a VM for rapid testing.

## Installation

### Install with the NixOS Live CD

1. Download the latest NixOS live CD from [here](https://nixos.org/download).
2. Create a bootable USB drive:

```sh
sudo dd bs=4M if=/path/to/nixos.iso of=/dev/sda conv=fsync oflag=direct status=progress
```

3. Boot from the USB drive.
4. Install NixOS from the live CD:

```sh
nix-shell -p git gnumake neovim
git clone https://github.com/khuedoan/homecloud
cd homecloud
# Remember to replace the placeholders
make install host=HOSTNAME disk=/dev/DISK
```
