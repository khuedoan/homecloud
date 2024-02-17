resource "proxmox_virtual_environment_vm" "nodes" {
  count       = 1
  name        = "${local.name_prefix}-${count.index}"
  description = "Staging node for https://github.com/khuedoan/homelab"
  node_name   = "proxmox"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024 * 8
  }

  bios = "ovmf"

  operating_system {
    type = "l26"
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = "c2:f5:cf:1f:3e:c0"
  }

  tags = [
    "homecloud",
    "staging"
  ]
}
