terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.38.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox:8006"
  insecure = true
}
