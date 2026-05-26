resource "aws_s3_bucket" "state" {
  bucket = var.aws_bucket_name

  tags = {
    Name        = var.aws_bucket_name
    Environment = "home-lab"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  region = var.aws_region
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

import {
  id = var.aws_bucket_name
  to = aws_s3_bucket.state
}

module "talos" {
  depends_on = [aws_s3_bucket.state]
  source     = "./modules/talos"

  providers = {
    proxmox = proxmox
  }

  image = {
    version = "1.13.0"
  }

  cluster = {
    name               = "lab"
    endpoint           = "10.13.37.25"
    gateway            = "10.13.37.1"
    talos_version      = "v1.13"
    proxmox_cluster    = "pve-cluster"
    kubernetes_version = "v1.35.0"
    extra_manifests    = []
  }

  nodes = {
    "ctrl-1" = {
      host_node    = "pve1"
      machine_type = "controlplane"
      ip           = "10.13.37.25"
      dns          = ["10.13.37.10"]
      vm_id        = 301
      cpu_cores    = 2
      ram          = 4096
      datastore_id = "vm_data"
    }
    "ctrl-2" = {
      host_node    = "pve2"
      machine_type = "controlplane"
      ip           = "10.13.37.26"
      dns          = ["10.13.37.10"]
      vm_id        = 302
      cpu_cores    = 2
      ram          = 6144
      datastore_id = "vm_data"
    }
    "ctrl-3" = {
      host_node    = "pve2"
      machine_type = "controlplane"
      ip           = "10.13.37.27"
      dns          = ["10.13.37.10"]
      vm_id        = 303
      cpu_cores    = 2
      ram          = 6144
      datastore_id = "vm_data"
    }
  }
}

module "proxmox_csi" {
  depends_on = [module.talos]
  source     = "./modules/storage/proxmox_csi"

  providers = {
    proxmox    = proxmox
    kubernetes = kubernetes
  }

  pve_cluster_name = "home-lab"
  pve_endpoint     = var.pve_endpoint
}

module "proxmox_csi_vols" {
  depends_on = [module.proxmox_csi]
  source     = "./modules/storage/proxmox_csi_vols"

  providers = {
    kubernetes = kubernetes
    restapi    = restapi
  }

  pve_cluster_name = "home-lab"
  volumes = {
    pv-sonarr = {
      node = "pve1"
      size = "4G"
    }
    pv-radarr = {
      node = "pve1"
      size = "4G"
    }
    pv-lidarr = {
      node = "pve1"
      size = "4G"
    }
    pv-prowlarr = {
      node = "pve1"
      size = "4G"
    }
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [module.talos]

  components_extra       = ["source-watcher"]
  embedded_manifests     = false
  kustomization_override = file("${path.root}/../cluster/flux-system/kustomization.yaml")
  path                   = "cluster"
  version                = "v2.8.8"
}

module "external_secrets" {
  depends_on = [module.talos]
  source     = "./modules/external-secrets"

  providers = {
    kubernetes = kubernetes
    aws        = aws
  }
}
