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
