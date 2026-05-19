locals {
  service_account = kubernetes_service_account_v1.external_secrets.metadata[0].name
  namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
  workload_identity_pool_id = google_iam_workload_identity_pool.external_secrets.workload_identity_pool_id
}

data "google_project" "this" {}

resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "kubernetes_service_account_v1" "external_secrets" {
  metadata {
    name      = "sa-external-secrets"
    namespace = "external-secrets"
  }
}

data "http" "cluster_jwks" {
  url = "${var.k8s_host}/openid/v1/jwks"
  ca_cert_pem = var.k8s_client_ca_cert
  client_cert_pem = var.k8s_client_cert
  client_key_pem = var.k8s_client_key
}

resource "google_iam_workload_identity_pool" "external_secrets" {
  workload_identity_pool_id = "home-lab"
  display_name             = "Home Lab Identity Pool"
}

resource "google_iam_workload_identity_pool_provider" "external_secrets" {
  workload_identity_pool_id = google_iam_workload_identity_pool.external_secrets.workload_identity_pool_id
  workload_identity_pool_provider_id = "home-lab-k8s-oidc"
  display_name = "Home Lab K8s OIDC"

  attribute_mapping = {
    "google.subject": "assertion.sub"
  }

  oidc {
    issuer_uri = var.k8s_host
    jwks_json  = data.http.cluster_jwks.response_body
  }
}

resource "google_project_iam_binding" "external_secrets" {
  project = data.google_project.this.project_id
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "principal://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${local.workload_identity_pool_id}/subject/ystem:serviceaccount:default:${local.service_account}"
  ]
}
