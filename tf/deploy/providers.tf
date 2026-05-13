terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.106.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">=0.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=3.1.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = ">=3.0.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure
  ssh {
    agent       = true
    username    = var.proxmox.username
    private_key = file("~/.ssh/id_ed25519")
  }
}

provider "kubernetes" {
  host                   = module.talos.kube_config.kubernetes_client_configuration.host
  client_certificate     = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
}
