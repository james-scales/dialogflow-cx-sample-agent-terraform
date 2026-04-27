variable "agent_id" {
  description = "Dialogflow CX agent ID (passed from agent module output)"
  type        = string
}

variable "policy_type_entity_type_id" {
  description = "Resource ID of the policy_type entity type (passed from entity_types module output)"
  type        = string
}

variable "incident_type_entity_type_id" {
  description = "Resource ID of the incident_type entity type — used to annotate theft, vandalism, and hit-and-run training phrases on the claim.file intent"
  type        = string
}