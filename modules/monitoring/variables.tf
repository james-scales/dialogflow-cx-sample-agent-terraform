variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "GCP region for the audit log GCS bucket (should match Dialogflow agent location)"
  type        = string
}

#---------- Notification ----------#
variable "alert_email_address" {
  description = "Email address to receive all Dialogflow security and operational alerts"
  type        = string
}

#---------- Audit log retention ----------#
variable "audit_log_bucket_name" {
  description = "Name of the GCS bucket for long-term audit log storage (created by this module)"
  type        = string
  default     = "dialogflow-cx-audit-logs"
}

variable "audit_log_retention_days" {
  description = "Number of days to retain audit logs in GCS before deletion (default: 365)"
  type        = number
  default     = 365
}

#---------- Alert thresholds ----------#
variable "webhook_failure_threshold" {
  description = "Number of webhook failures within the evaluation window before alerting (default: 5)"
  type        = number
  default     = 5
}

variable "detectintent_error_threshold" {
  description = "Number of detectIntent errors within the evaluation window before alerting (default: 10)"
  type        = number
  default     = 10
}
