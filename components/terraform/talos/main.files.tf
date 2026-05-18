locals {
  machine_secrets = talos_machine_secrets.this.machine_secrets
  project_root    = "${path.root}/../../../output/"
}

resource "local_file" "talos_machine_secrets" {
  content = yamlencode({
    cluster    = local.machine_secrets.cluster
    secrets    = local.machine_secrets.secrets
    trustdinfo = local.machine_secrets.trustdinfo
    certs = {
      etcd = {
        crt = local.machine_secrets.certs.etcd.cert
        key = local.machine_secrets.certs.etcd.key
      }
      k8s = {
        crt = local.machine_secrets.certs.k8s.cert
        key = local.machine_secrets.certs.k8s.key
      }
      k8saggregator = {
        crt = local.machine_secrets.certs.k8s_aggregator.cert
        key = local.machine_secrets.certs.k8s_aggregator.key
      }
      k8sserviceaccount = {
        key = local.machine_secrets.certs.k8s_serviceaccount.key
      }
      os = {
        crt = local.machine_secrets.certs.os.cert
        key = local.machine_secrets.certs.os.key
      }
    }
  })
  filename = "${local.project_root}/talos-machine-secrets.yaml"
}

resource "local_file" "machine_configs" {
  for_each        = data.talos_machine_configuration.this
  content         = each.value.machine_configuration
  filename        = "${local.project_root}/talos-machine-config-${each.key}.yaml"
  file_permission = "0600"
}

resource "local_file" "talos_config" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = "${local.project_root}/talos-config.yaml"
  file_permission = "0600"
}

resource "local_file" "kube_config" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = "${local.project_root}/kube-config.yaml"
  file_permission = "0600"
}
