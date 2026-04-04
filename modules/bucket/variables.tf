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
