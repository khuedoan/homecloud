resource "proxmox_virtual_environment_vm" "fake_laptop" {
  name        = "${local.name_prefix}-fake-laptop"
  description = "Staging initial controller for https://github.com/khuedoan/homelab, acting as a laptop connected to the same LAN using wired connection"
  node_name   = "proxmox"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1024 * 4
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/nixos-23.11-gnome-x86_64-linux.iso"
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

  tags = [
    "homecloud",
    "staging"
  ]
}
