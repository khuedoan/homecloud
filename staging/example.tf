resource "proxmox_virtual_environment_file" "ubuntu2204" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"

  source_file {
    path = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  }
}

resource "random_password" "testing" {
  length  = 16
  special = false
}

resource "proxmox_virtual_environment_vm" "foobar" {
  name        = "foobar"
  description = "Managed by OpenTofu (Terraform)"
  node_name   = "proxmox"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024 * 2
  }

  disk {
    file_id   = proxmox_virtual_environment_file.ubuntu2204.id
    interface = "scsi0"
  }

  bios = "ovmf"

  operating_system {
    type = "l26"
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "ubuntu"
      password = random_password.testing.result
    }
  }

  tags = [
    "staging"
  ]
}
