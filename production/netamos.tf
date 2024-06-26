resource "proxmox_virtual_environment_vm" "netamos" {
  name        = "netamos"
  description = "Netamos"
  node_name   = "proxmox"

  cpu {
    cores = 8
  }

  memory {
    dedicated = 1024 * 16
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/nixos-23.11-gnome-x86_64-linux.iso"
    interface = "ide3"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 128
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
    "production"
  ]
}
