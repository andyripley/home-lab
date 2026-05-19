module "gcp-setup" {
  source = "./modules/gcp-setup"

  bucket_name  = var.gcp_bucket_name
  location     = var.gcp_location
  pve_username = var.pve_username
  pve_password = var.pve_password
}

import {
  id = var.gcp_bucket_name
  to = module.gcp-setup.google_storage_bucket.terraform_state
}

module "talos" {
  depends_on = [module.gcp-setup]
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
    kubernetes_version = "v1.36.0"
    extra_manifests = [
      #Traefik and Gateway API CRDs.  
      "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml",
      "https://raw.githubusercontent.com/traefik/traefik/v3.5/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml",
      "https://raw.githubusercontent.com/external-secrets/external-secrets/v2.5.0/deploy/crds/bundle.yaml"
    ]
  }

  nodes = {
    "ctrl-1" = {
      host_node    = "pve1"
      machine_type = "controlplane"
      ip           = "10.13.37.25"
      mac_address  = "BC:24:11:00:00:25"
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
      mac_address  = "BC:24:11:00:00:26"
      dns          = ["10.13.37.10"]
      vm_id        = 302
      cpu_cores    = 2
      ram          = 4096
      datastore_id = "vm_data"
    }
  }
}

module "proxmox_csi" {
  depends_on = [module.gcp-setup, module.talos]
  source     = "./modules/storage/proxmox_csi"

  providers = {
    proxmox    = proxmox
    kubernetes = kubernetes
  }

  pve_cluster_name = "home-lab"
  pve_endpoint     = var.pve_endpoint
}

module "proxmox_csi_vols" {
  source = "./modules/storage/proxmox_csi_vols"
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
  embedded_manifests     = true
  kustomization_override = file("${path.root}/../cluster/flux-system/kustomization.yaml")
  path                   = "cluster"
}

module "external_secrets" {
  source = "./modules/external-secrets"

  providers = {
    kubernetes = kubernetes
    google     = google
  }

  k8s_host           = module.talos.kube_config.kubernetes_client_configuration.host
  k8s_client_ca_cert = base64decode(module.talos.kube_config.kubernetes_client_configuration.ca_certificate)
  k8s_client_cert    = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_certificate)
  k8s_client_key     = base64decode(module.talos.kube_config.kubernetes_client_configuration.client_key)
}

