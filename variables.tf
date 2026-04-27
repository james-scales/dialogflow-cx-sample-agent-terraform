variable "zone" {
  default = "us-central1-a"
  type    = string
}

variable "project_name" {
  description = "Human-readable project name applied as a resource label"
  type        = string
  default     = "dev-project-all"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod) applied as a resource label"
  type        = string
  default     = "dev"
}

#---------- Terraform service account ----------#
# SA key creation is disabled at org level. Auth uses ADC + impersonation.
# Run: gcloud iam service-accounts add-iam-policy-binding <SA_EMAIL> \
#        --member="user:<YOUR_EMAIL>" --role="roles/iam.serviceAccountTokenCreator"
variable "terraform_sa_email" {
  description = "Service account Terraform impersonates via ADC — no key file required"
  type        = string
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

variable "dialogflow_cx_location" {
  description = "Dialogflow CX region — must be a supported CX location (us-central1, us-east1, us-west1, europe-west1, etc.). Separate from project_region because not all GCP regions support Dialogflow CX."
  type        = string
  default     = "us-east1"
}

#---------- Bucket (module: bucket) ----------#
# Added for modularisation — previously hardcoded in terraform/bucket.tf
variable "bucket_name" {
  description = "Name of the GCS bucket used for Dialogflow CX audio exports"
  type        = string
  default     = "dialogflowcx-audio-exports-42326"
}

variable "bucket_location" {
  description = "GCS bucket location (e.g. US, EU, us-central1)"
  type        = string
  default     = "us-east4"
}

variable "webhook_uri" {
  description = "HTTPS URI of the policy lookup backend (Cloud Run, Cloud Function, etc.)"
  type        = string
}

variable "github_repo_uri" {
  description = "GitHub repository URI for Dialogflow CX agent version sync. Null = git integration disabled."
  type        = string
  default     = null
}


