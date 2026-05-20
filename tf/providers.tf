terraform {
  backend "gcs" {
    bucket = "home-lab-state"
    prefix = "tofu"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
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
      version = "~> 3.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = "~> 1.8"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_location
}

provider "proxmox" {
  endpoint = var.pve_endpoint
  insecure = false
  username = var.pve_username
  password = var.pve_password
  ssh {
    agent = true
  }
}

provider "kubernetes" {
  host                   = module.talos.kube_config.kubernetes_client_configuration.host
  client_certificate     = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
}

provider "restapi" {
  uri                  = var.pve_endpoint
  insecure             = false
  write_returns_object = true
  debug = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=${var.pve_api_token}"
  }
}

provider "flux" {
  kubernetes = {
    host                   = module.talos.kube_config.kubernetes_client_configuration.host
    client_certificate     = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
  }
  git = {
    url = "https://github.com/andyripley/home-lab.git"
    http = {
      username = "git"
      password = var.github_pat_token
    }
  }
}
