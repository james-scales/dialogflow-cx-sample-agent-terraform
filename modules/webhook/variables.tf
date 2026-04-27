variable "agent_id" {
  description = "Full resource ID of the Dialogflow CX agent"
  type        = string
}

variable "webhook_uri" {
  description = "HTTPS URI of the policy lookup backend (Cloud Run, Cloud Function, etc.)"
  type        = string
}