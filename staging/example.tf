resource "random_password" "testing" {
  length  = 16
  special = false
}

resource "proxmox_virtual_environment_vm" "example" {
  name        = "example"
  description = "Managed by OpenTofu (Terraform)"
  node_name   = "proxmox"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024 * 2
  }

  disk {
    file_id   = "local:iso/jammy-server-cloudimg-amd64.img"
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
    "opentofu",
    "staging"
  ]
}
