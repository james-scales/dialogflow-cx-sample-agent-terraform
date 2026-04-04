variable "agent_id" {
  description = "Dialogflow CX agent ID (passed from agent module output)"
  type        = string
}

variable "size_entity_type_id" {
  description = "Resource ID of the size entity type (passed from entity_types module output)"
  type        = string
}
