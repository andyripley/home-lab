resource "kubernetes_namespace_v1" "sealed-secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "kubernetes_secret_v1" "sealed-secrets-key" {
  depends_on = [kubernetes_namespace_v1.sealed-secrets]
  type       = "kubernetes.io/tls"

  metadata {
    name      = "sealed-secrets-bootstrap-key"
    namespace = "sealed-secrets"
    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }

  data = {
    "tls.crt" = coalesce(var.certificate_path, file("${path.module}/certs/sealed-secrets.cert"))
    "tls.key" = coalesce(var.certificate_key_path, file("${path.module}/certs/sealed-secrets.key"))
  }
}
