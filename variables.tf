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

# #---------- Network / mTLS (module: network) ----------#
# variable "vpc_network_id" {
#   description = "Self-link or ID of the VPC network for the PSC endpoint (e.g. projects/my-project/global/networks/default)"
#   type        = string
# }

# variable "client_ca_cert_pem" {
#   description = "PEM-encoded public CA certificate used to validate mTLS client certificates on webhook calls"
#   type        = string
# }

# #---------- VPC Service Controls (module: vpc_sc) ----------#
# variable "org_id" {
#   description = "GCP Organization ID — required to create or reference the org-level Access Policy"
#   type        = string
# }

# variable "existing_access_policy_name" {
#   description = "Name of an existing org Access Policy (format: 'accessPolicies/1234567890'). Set to null to create a new one."
#   type        = string
#   default     = null
# }

# variable "vpc_sc_ingress_identities" {
#   description = "IAM identities allowed to call Dialogflow APIs from outside the VPC-SC perimeter (e.g. 'group:devs@example.com')"
#   type        = list(string)
#   default     = []
# }

# variable "vpc_sc_ingress_access_level" {
#   description = "Optional Access Level to further restrict ingress (e.g. 'accessPolicies/123/accessLevels/corp_network'). Null = any source for listed identities."
#   type        = string
#   default     = null
# }

# variable "vpc_sc_egress_identities" {
#   description = "Additional IAM identities allowed to call KMS and Secret Manager from within the perimeter (Dialogflow service agent is always included)"
#   type        = list(string)
#   default     = []
# }

#---------- Monitoring (module: monitoring) ----------#
# variable "alert_email_address" {
#   description = "Email address to receive Dialogflow security and operational alerts"
#   type        = string
# }

#---------- KMS (module: kms) ----------#
# key_ring_name, crypto_key_name, rotation_period, protection_level use module defaults.
# Override in tfvars only if needed.

#---------- Secrets (module: secrets) ----------#
# variable "secret_next_rotation_time" {
#   description = "Timestamp of the first Secret Manager rotation notification (RFC3339, e.g. 2025-07-01T00:00:00Z). Set to null to disable rotation schedule."
#   type        = string
#   default     = null
# }

# #---------- IAM (module: iam) ----------#
# variable "agent_builder_group" {
#   description = "Google group email for Dialogflow CX Agent Builders (e.g. dialogflow-agents@example.com)"
#   type        = string
# }

# variable "webhook_developer_group" {
#   description = "Google group email for Dialogflow CX Webhook Developers (e.g. dialogflow-webhooks@example.com)"
#   type        = string
# }

# variable "cicd_service_account_email" {
#   description = "Service account email used by CI/CD pipelines to deploy Dialogflow CX resources via Terraform"
#   type        = string
# }

