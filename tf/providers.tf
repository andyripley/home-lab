terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket = var.aws_bucket_name
    region = var.aws_region
    key    = "tofu/home-lab.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
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
      source  = "fluxcd/flux"
      version = "~> 1.8"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "proxmox" {
  endpoint = var.pve_endpoint
  insecure = false
  username = local.pve_username
  password = local.pve_password
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
  debug                = true

  headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "PVEAPIToken=${local.pve_api_token}"
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
      password = local.github_pat_token
    }
  }
}
