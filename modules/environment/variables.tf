variable "agent_id" {
  description = "Full resource ID of the Dialogflow CX agent"
  type        = string
}

variable "start_flow_version_id" {
  description = "Resource ID of the Default Start Flow version to pin (from version module output)"
  type        = string
}