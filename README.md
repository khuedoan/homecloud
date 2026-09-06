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

- Nixie installs NixOS on the metal host through PXE.
- Incus provides virtual machines, containers, and management APIs.
- NixOS configures the host and its services.

I use this project for three main purposes:

- Offsite backup: the metal host is located at my parents' house in a different
  region of my country, with a separate disk that I mount to a VM running Minio.
- External monitoring system for my main monitoring system: [quis custodiet ipsos custodes?](https://en.wikipedia.org/wiki/Quis_custodiet_ipsos_custodes%3F)
- A flexible playground: because my main Kubernetes cluster runs on bare-metal nodes,
  it lacks flexibility for quick experimentation with things like PXE boot, BSD distros, etc.
  With a hypervisor, I can easily spin up a VM for rapid testing.

## Installation

### Metal host

Enable UEFI PXE boot on the host. Then start the Nixie PXE server and installation:

```sh
make install
```

The command uses Ethernet interface `eth0` and SSH key `~/.ssh/id_ed25519`.

Keep the same DHCP lease while the installer reboots into the installed system.
A DHCP reservation is the most reliable option. Nixie writes the IP address and
machine ID hash to `hosts.json`. Read the address with:

```sh
jq -r '.homecloud.ip' hosts.json
```

Use one-time PXE boot. The host must boot from the local disk after installation.

## User management

Add the person to `services.kanidm.provision.persons`.

```nix
persons.alice = {
  displayName = "Alice Example";
  mailAddresses = [ "alice@example.com" ];
  # Membership in `incus-users` grants full administrative access to Incus.
  groups = [ "incus-users" ];
};
```

Generate an enrollment link interactively:

```sh
make enroll username=khuedoan
```

## Project structure

- `configuration.nix` configures the metal host and its services.
- `hosts/installer.nix` configures the Nixie PXE installer.
- `hosts/testvm.nix` adds the settings for the local QEMU test VM.
- `hosts.json` stores the host address and installation identity that Nixie
  manages.
- `flake.nix` defines the installer, the metal host, the test VM, and the
  development shell.
- `Makefile` defines the installation, deployment, enrollment, and development
  commands.
