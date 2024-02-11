resource "proxmox_virtual_environment_download_file" "ubuntu2204" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_download_file" "nixos2311" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://channels.nixos.org/nixos-23.11/latest-nixos-gnome-x86_64-linux.iso"
}


locals {
  nixos_vm_images = [
  ]
  nixos_lxc_images = {
    # TODO get image ID automatically, maybe with data.external
    "base"        = "/nix/store/drkh5k2lc3nybvanpsvxrjmsc7p47fl9-tarball"
    "devbox"      = "/nix/store/22xh3bjng1a4cqn674bh13j3m4r4g6l8-tarball"
  }
}

resource "proxmox_virtual_environment_file" "nixos_lxc_images" {
  for_each = local.nixos_lxc_images

  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "proxmox"

  source_file {
    file_name = "nixos-${each.key}.tar.xz"
    path      = "${each.value}/tarball/nixos-system-x86_64-linux.tar.xz"
  }
}
