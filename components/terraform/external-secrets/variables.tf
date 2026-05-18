variable "certificate_path" {
  description = "Certificate file path for Sealed Secrets"
  type        = string
  default     = null
}

variable "certificate_key_path" {
  description = "Certificate key file path for Sealed Secrets"
  type        = string
  default     = null
}
