variable "zone" {
  default = "us-central1-a"
  type    = string
}
variable "project_number" {
  description = "GCP Project Number"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_region" {
  description = "Project Region"
  type        = string
}

#---------- Bucket (module: bucket) ----------#
# Added for modularisation — previously hardcoded in terraform/bucket.tf
variable "bucket_name" {
  description = "Name of the GCS bucket used for Dialogflow CX audio exports"
  type        = string
  default     = "scales-dev-dialogflowcx-bucket"
}

variable "bucket_location" {
  description = "GCS bucket location (e.g. US, EU, us-central1)"
  type        = string
  default     = "US"
}

