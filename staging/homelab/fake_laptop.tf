resource "proxmox_virtual_environment_download_file" "nixos2311" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://channels.nixos.org/nixos-23.11/latest-nixos-gnome-x86_64-linux.iso"
}

resource "proxmox_virtual_environment_vm" "fake_laptop" {
  count       = 1
  name        = "${local.name_prefix}-fake-laptop"
  description = "Staging initial controller for https://github.com/khuedoan/homelab, acting as a laptop connected to the same LAN using wired connection"
  node_name   = "proxmox"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024 * 2
  }

  cdrom {
    enabled = true
    file_id = proxmox_virtual_environment_download_file.nixos2311.id
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 32
    file_format  = "raw"
  }

  bios = "ovmf"

  operating_system {
    type = "l26"
  }

  network_device {
    bridge = "vmbr0"
  }

  tags = [
    "opentofu",
    "staging"
  ]
}
