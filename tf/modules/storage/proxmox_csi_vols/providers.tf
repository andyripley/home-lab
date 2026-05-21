terraform {
  required_version = ">= 1.11.0"

  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=3.1.0"
    }
  }
}
