terraform {
  backend "pg" {
    conn_str = "postgres://proxmox/tfstate_staging"
  }

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox:8006"
  insecure = true
}
