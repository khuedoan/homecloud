terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.46.2"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.1.11:8006"
  insecure = true
}
