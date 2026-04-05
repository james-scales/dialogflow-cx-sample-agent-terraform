variable "project_id" {
  description = "GCP Project ID of the project being protected by the service perimeter"
  type        = string
}

variable "project_number" {
  description = "GCP Project Number — used to identify the project in the perimeter resource list and construct service agent emails"
  type        = string
}

variable "org_id" {
  description = "GCP Organization ID — required to create or reference the org-level Access Policy"
  type        = string
}

#---------- Access Policy ----------#
variable "existing_access_policy_name" {
  description = "Name of an existing Access Policy to use (format: 'accessPolicies/1234567890'). Set to null to create a new one. Most organizations already have an Access Policy — check before setting to null."
  type        = string
  default     = null
}

variable "access_policy_title" {
  description = "Display title for a newly created Access Policy (ignored if existing_access_policy_name is set)"
  type        = string
  default     = "Dialogflow CX Access Policy"
}

#---------- Service Perimeter ----------#
variable "perimeter_name" {
  description = "Short name of the service perimeter (no spaces, used in the resource path)"
  type        = string
  default     = "dialogflow_cx_perimeter"
}

variable "perimeter_title" {
  description = "Human-readable title for the service perimeter"
  type        = string
  default     = "Dialogflow CX Service Perimeter"
}

#---------- Ingress ----------#
# IAM member strings allowed to call Dialogflow APIs from outside the perimeter.
# Format: "serviceAccount:sa@project.iam.gserviceaccount.com", "group:grp@example.com"
variable "ingress_identities" {
  description = "List of IAM identities permitted to call restricted APIs from outside the perimeter"
  type        = list(string)
  default     = []
}

variable "ingress_access_level" {
  description = "Optional Access Level resource name to further restrict ingress (e.g. 'accessPolicies/123/accessLevels/corporate_network'). Set to null to allow any source for listed identities."
  type        = string
  default     = null
}

#---------- Egress ----------#
# Additional IAM identities (beyond the Dialogflow service agent) allowed to
# call Cloud KMS and Secret Manager from within the perimeter.
variable "egress_identities" {
  description = "Additional IAM identities allowed to call KMS and Secret Manager from within the perimeter (Dialogflow service agent is always included)"
  type        = list(string)
  default     = []
}
