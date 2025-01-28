resource "proxmox_virtual_environment_container" "devbox" {
  description = "Development instance, can be used as a bastion host"
  node_name   = "proxmox"

  cpu {
    cores = 4
  }

  memory {
    dedicated = 1024 * 4
  }

  operating_system {
    template_file_id = "local:vztmpl/nixos-devbox.tar.xz"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
  }

  network_interface {
    name = "veth0"
  }

  initialization {
    hostname = "devbox"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  features {
    nesting = true
  }

  console {
    type = "console"
  }

  tags = [
    "homecloud",
    "staging"
  ]
}

module "devbox" {
  source = "../modules/nixos-vm/"
  name   = "devbox"
  nixos = {
    flake = "git+https://github.com/khuedoan/nixos-setup"
    host  = "ryzentower"
  }
  cpu = {
    cores = 4
  }
  memory = {
    dedicated = 16
  }
  disks = {
    os = {
      size = 128
    }
  }
}
