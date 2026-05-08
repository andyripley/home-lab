terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.106.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "3.0.0"
    }
  }
}
