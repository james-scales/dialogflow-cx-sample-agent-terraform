variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_number" {
  description = "GCP Project Number — used to construct the Dialogflow Service Agent email"
  type        = string
}

variable "location" {
  description = "GCP region for the KMS key ring (must match the Dialogflow CX agent location)"
  type        = string
}

variable "key_ring_name" {
  description = "Name of the KMS key ring"
  type        = string
  default     = "dialogflow-cx-keyring"
}

variable "crypto_key_name" {
  description = "Name of the CMEK crypto key used to encrypt Dialogflow CX agent data at rest"
  type        = string
  default     = "dialogflow-cx-cmek"
}

variable "rotation_period" {
  description = "Automatic key rotation period in seconds (default: 7776000s = 90 days)"
  type        = string
  default     = "7776000s"
}

variable "protection_level" {
  description = "Key protection level: SOFTWARE (default) or HSM. HSM provides hardware-backed security at higher cost."
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.protection_level)
    error_message = "protection_level must be SOFTWARE or HSM."
  }
}
