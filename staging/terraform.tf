terraform {
  backend "pg" {
    conn_str = "postgres://proxmox/tfstate_staging"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.57.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.5.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox:8006"
  insecure = true
}
