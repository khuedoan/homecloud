terraform {
  backend "pg" {
    conn_str = "postgres://proxmox/tfstate_production"
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.57.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox:8006"
  insecure = true
}
