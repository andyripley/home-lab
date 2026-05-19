resource "proxmox_virtual_environment_role" "this" {
  role_id = "CSI"
  privileges = [
    "VM.Audit",
    "VM.Config.Disk",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit"
  ]
}

resource "proxmox_virtual_environment_user" "this" {
  user_id = "kubernetes-csi@pve"
  comment = "User for Proxmox CSI Plugin"
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.this.role_id
  }
}

resource "proxmox_user_token" "this" {
  comment               = "Token for Proxmox CSI Plugin"
  token_name            = "csi"
  user_id               = proxmox_virtual_environment_user.this.user_id
  privileges_separation = false
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "csi-proxmox"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    name      = "proxmox-csi-plugin"
    namespace = kubernetes_namespace_v1.this.id
  }

  data = {
    "config.yaml" = <<EOF
clusters:
- url: "${var.pve_endpoint}/api2/json"
  insecure: ${var.insecure}
  token_id: "${proxmox_user_token.this.id}"
  token_secret: "${element(split("=", proxmox_user_token.this.value), length(split("=", proxmox_user_token.this.value)) - 1)}"
  region: ${var.pve_cluster_name}
EOF
  }
}
