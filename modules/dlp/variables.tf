variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "GCP region for DLP templates and job trigger (should match Dialogflow agent location)"
  type        = string
}

#---------- GCS scan target ----------#
variable "gcs_bucket_name" {
  description = "Name of the GCS bucket to scan for PII (the Dialogflow CX audio export and agent export bucket)"
  type        = string
}

variable "bytes_limit_per_file" {
  description = "Maximum bytes to scan per file (default: 10MB). Increase for large agent export JSON files."
  type        = number
  default     = 10737418240
}

#---------- Scan schedule ----------#
variable "scan_recurrence_period" {
  description = "How often to run the DLP scan (default: 86400s = daily)"
  type        = string
  default     = "86400s"
}

#---------- BigQuery findings ----------#
variable "findings_dataset_id" {
  description = "BigQuery dataset ID for storing DLP scan findings (created by this module)"
  type        = string
  default     = "dialogflow_dlp_findings"
}

variable "findings_table_expiration_ms" {
  description = "Default table expiration in milliseconds for DLP findings tables (default: 90 days)"
  type        = number
  default     = 7776000000
}

#---------- Optional Pub/Sub alerting ----------#
variable "findings_pubsub_topic" {
  description = "Optional Pub/Sub topic to publish DLP findings notifications to (format: 'projects/PROJECT_ID/topics/TOPIC_ID'). Set to null to disable."
  type        = string
  default     = null
}
