variable "agent_id" {
  description = "Dialogflow CX agent ID (passed from agent module output)"
  type        = string
}

# Previously hardcoded entity values in entity-types.tf.
# Now configurable — add new sizes or synonyms here without touching module code.
variable "size_entities" {
  description = "List of size entity values and their synonyms"
  type = list(object({
    value    = string
    synonyms = list(string)
  }))
  default = [
    { value = "small", synonyms = ["little", "small", "tiny"] },
    { value = "medium", synonyms = ["medium", "regular", "average"] },
    { value = "large", synonyms = ["big", "giant", "large"] },
  ]
}
