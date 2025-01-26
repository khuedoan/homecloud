resource "proxmox_virtual_environment_vm" "example" {
  name      = "example"
  node_name = "proxmox"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024 * 8
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/nixos-24.11.20250123.035f8c0-x86_64-linux.iso"
    interface = "ide3"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
  }

  boot_order = [
    "scsi0",
    "ide3",
  ]

  bios = "ovmf"

  operating_system {
    type = "l26"
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  tags = [
    "homecloud",
  ]
}

module "example_deploy" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one?ref=1.6.0"
  nixos_system_attr      = "../global/images#nixosConfigurations.nixos.config.system.build.toplevel"
  nixos_partitioner_attr = "../global/images#nixosConfigurations.nixos.config.system.build.diskoScript"
  target_host            = proxmox_virtual_environment_vm.example.ipv4_addresses[1][0]
  instance_id            = proxmox_virtual_environment_vm.example.ipv4_addresses[1][0]
}
