variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "GCP region for user-managed secret replication (should match Dialogflow agent location)"
  type        = string
}

variable "rotation_period" {
  description = "How often to send rotation notifications after next_rotation_time (default: 7776000s = 90 days)"
  type        = string
  default     = "7776000s"
}

variable "next_rotation_time" {
  description = "Timestamp of the first rotation notification (RFC3339, e.g. 2025-07-01T00:00:00Z). Set to null to disable rotation schedule."
  type        = string
  default     = null
}

#---------- Secret definitions ----------#
# Map of secret_id → { purpose, accessor }
# purpose:  label value for identification (e.g. "webhook-auth", "github-token")
# accessor: IAM member granted secretAccessor at runtime.
#           Format: "serviceAccount:svc@project.iam.gserviceaccount.com" or "group:grp@example.com"
#           Leave as "" to skip the IAM binding (bind manually or via a separate module).
variable "secrets" {
  description = "Map of secrets to create. Key = secret_id, value = { purpose, accessor }."
  type = map(object({
    purpose  = string
    accessor = string
  }))
  default = {
    "dialogflow-webhook-auth-token" = {
      purpose  = "webhook-auth"
      accessor = ""
    }
    "dialogflow-github-token" = {
      purpose  = "github-integration"
      accessor = ""
    }
  }
}
