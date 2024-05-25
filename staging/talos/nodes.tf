resource "proxmox_virtual_environment_download_file" "talos" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"

  # Latest version with QEMU agent
  # https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=metal&target=metal
  url       = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.7.2/metal-amd64.iso"
  file_name = "talos-metal-amd64.iso"
}

resource "proxmox_virtual_environment_vm" "nodes" {
  name        = "talos"
  description = "Talos node"
  node_name   = "proxmox"

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 1024 * 8
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/talos-metal-amd64.iso"
    interface = "ide3"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 64
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
    "production"
  ]
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = "example-cluster"
  machine_type     = "controlplane"
  cluster_endpoint = "https://${proxmox_virtual_environment_vm.nodes.ipv4_addresses[0]}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = "example-cluster"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes = [
    # TODO do not hardcode IP, and make it work while I'm not at home
    proxmox_virtual_environment_vm.nodes.ipv4_addresses[0]
  ]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = proxmox_virtual_environment_vm.nodes.ipv4_addresses[0]
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sda"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = proxmox_virtual_environment_vm.nodes.ipv4_addresses[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = proxmox_virtual_environment_vm.nodes.ipv4_addresses[0]
}

resource "local_file" "kubeconfig" {
  content         = replace(data.talos_cluster_kubeconfig.this.kubeconfig_raw, "cluster.local", proxmox_virtual_environment_vm.nodes.ipv4_addresses[0])
  filename        = "${path.root}/kubeconfig.yaml"
  file_permission = "0600"
}
