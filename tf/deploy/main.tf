module "talos" {
  source = "./talos"

  providers = {
    proxmox = proxmox
  }

  image = {
    version   = "1.13.0"
    schematic = file("${path.module}/talos/configs/talos-schematic.yaml")
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
      "https://raw.githubusercontent.com/traefik/traefik/v3.5/docs/content/reference/dynamic-configuration/kubernetes-gateway-rbac.yml"
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

module "sealed-secrets" {
  depends_on = [module.talos]
  source = "./bootstrap/sealed-secrets"

  providers = {
    kubernetes = kubernetes
  }

  cert = {
    certificate_path      = file("${path.module}/bootstrap/sealed-secrets/certs/sealed-secrets.cert")
    certificate_key_path  = file("${path.module}/bootstrap/sealed-secrets/certs/sealed-secrets.key")
  }
}

module "proxmox_csi" {
  depends_on = [module.talos]
  source = "./bootstrap/proxmox-csi"

  providers = {
    proxmox = proxmox
    kubernetes = kubernetes
  }

  proxmox = var.proxmox
}

resource "local_file" "talos_machine_secrets" {
  content = yamlencode({
    cluster    = module.talos.machine_secrets.cluster
    secrets    = module.talos.machine_secrets.secrets
    trustdinfo = module.talos.machine_secrets.trustdinfo
    certs = {
      etcd = {
        crt = module.talos.machine_secrets.certs.etcd.cert
        key = module.talos.machine_secrets.certs.etcd.key
      }
      k8s = {
        crt = module.talos.machine_secrets.certs.k8s.cert
        key = module.talos.machine_secrets.certs.k8s.key
      }
      k8saggregator = {
        crt = module.talos.machine_secrets.certs.k8s_aggregator.cert
        key = module.talos.machine_secrets.certs.k8s_aggregator.key
      }
      k8sserviceaccount = {
        key = module.talos.machine_secrets.certs.k8s_serviceaccount.key
      }
      os = {
        crt = module.talos.machine_secrets.certs.os.cert
        key = module.talos.machine_secrets.certs.os.key
      }
    }
  })
  filename = "../../output/talos-machine-secrets.yaml"
}

resource "local_file" "machine_configs" {
  for_each        = module.talos.machine_config
  content         = each.value.machine_configuration
  filename        = "../../output/talos-machine-config-${each.key}.yaml"
  file_permission = "0600"
}

resource "local_file" "talos_config" {
  content         = module.talos.client_configuration.talos_config
  filename        = "../../output/talos-config.yaml"
  file_permission = "0600"
}

resource "local_file" "kube_config" {
  content         = module.talos.kube_config.kubeconfig_raw
  filename        = "../../output/kube-config.yaml"
  file_permission = "0600"
}

