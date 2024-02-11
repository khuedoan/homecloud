resource "proxmox_virtual_environment_container" "uptime_kuma" {
  description = "Uptime Kuma (self-hosted monitoring tool)"
  node_name   = "proxmox"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024 * 1
  }

  operating_system {
    template_file_id = "local:vztmpl/nixos-base.tar.xz"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  network_interface {
    name = "veth0"
  }

  initialization {
    hostname = "uptime-kuma"

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
    "opentofu",
    "production"
  ]
}
