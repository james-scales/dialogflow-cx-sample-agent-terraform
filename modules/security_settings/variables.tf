variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for security settings — must match the agent's location"
  type        = string
}

variable "display_name" {
  description = "Human-readable name for the security settings"
  type        = string
  default     = "insurance-security-settings"
}