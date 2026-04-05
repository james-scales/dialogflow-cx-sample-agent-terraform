variable "project_id" {
  description = "GCP Project ID where IAM roles and bindings are created"
  type        = string
}

#---------- Group-based access ----------#
# Security standard: all permissions must be assigned to groups, not individual users.

variable "agent_builder_group" {
  description = "Google group email for Dialogflow CX Agent Builders (e.g. dialogflow-agents@example.com)"
  type        = string
}

variable "webhook_developer_group" {
  description = "Google group email for Dialogflow CX Webhook Developers (e.g. dialogflow-webhooks@example.com)"
  type        = string
}

#---------- CI/CD service account ----------#
variable "cicd_service_account_email" {
  description = "Service account email used by CI/CD pipelines to deploy Dialogflow CX resources via Terraform"
  type        = string
}
