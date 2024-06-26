# Each cluster manage its own image, in case the image configuration changes
resource "proxmox_virtual_environment_download_file" "talos" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"

  # Latest version with QEMU agent
  # https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fqemu-guest-agent&platform=metal&target=metal
  url       = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.7.2/metal-amd64.iso"
  file_name = "talos-metal-amd64-${var.name}.iso"
}

resource "proxmox_virtual_environment_vm" "nodes" {
  count = var.masters.count

  name        = "${var.name}-master-${count.index}"
  description = "Talos node"
  node_name   = "proxmox"

  cpu {
    cores = var.masters.cpu
    type  = "host"
  }

  memory {
    dedicated = 1024 * var.masters.memory
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_virtual_environment_download_file.talos.id
    interface = "ide3"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.masters.disk
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
    "kubernetes",
    "master",
    "talos-${var.name}",
  ]
}

locals {
  # TODO do I really need this hack to lookup the node IP??
  # https://www.talos.dev/v1.7/talos-guides/network/predictable-interface-names/
  node_interface       = "enx${lower(replace(proxmox_virtual_environment_vm.nodes[0].network_device[0].mac_address, ":", ""))}"
  node_interface_index = index(proxmox_virtual_environment_vm.nodes[0].network_interface_names, local.node_interface)
  node_ip              = proxmox_virtual_environment_vm.nodes[0].ipv6_addresses[local.node_interface_index][0]
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = var.name
  machine_type     = "controlplane"
  cluster_endpoint = "https://[${local.node_ip}]:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes = [
    local.node_ip
  ]
}

resource "talos_machine_configuration_apply" "this" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = local.node_ip
  endpoint                    = local.node_ip
  config_patches = [
    yamlencode({
      machine = {
        install = {
          image = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.7.2" # see factory link above
          disk  = "/dev/sda"
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = local.node_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.node_ip
}

resource "local_file" "kubeconfig" {
  content         = replace(data.talos_cluster_kubeconfig.this.kubeconfig_raw, "cluster.local", local.node_ip)
  filename        = "${path.root}/kubeconfig.yaml"
  file_permission = "0600"
}
