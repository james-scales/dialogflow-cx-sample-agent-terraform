variable "bucket_name" {
  description = "Name of the GCS bucket used for Dialogflow CX audio exports"
  type        = string
  default     = "dialogflowcx-audio-exports-42326"
}

variable "bucket_location" {
  description = "GCS bucket location (e.g. US, EU, us-central1)"
  type        = string
  default     = "US"
}
