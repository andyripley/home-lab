variable "k8s_host" {
  description = "The Kubernetes API server host"
  type        = string
  sensitive   = true
}

variable "k8s_client_ca_cert" {
  description = "The client CA certificate for authenticating to the Kubernetes API"
  type        = string
  sensitive   = true
}

variable "k8s_client_cert" {
  description = "The client certificate for authenticating to the Kubernetes API"
  type        = string
  sensitive   = true
}

variable "k8s_client_key" {
  description = "The client key for authenticating to the Kubernetes API"
  type        = string
  sensitive   = true
}
