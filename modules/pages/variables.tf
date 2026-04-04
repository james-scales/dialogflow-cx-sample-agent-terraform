variable "agent_start_flow" {
  description = "Resource name of the agent's default start flow (passed from agent module output)"
  type        = string
}

variable "size_entity_type_id" {
  description = "Resource ID of the size entity type (passed from entity_types module output)"
  type        = string
}

variable "store_location_message" {
  description = "Entry fulfillment message for the Store Location page"
  type        = string
  default     = "Our store is located at 1007 Mountain Drive, Gotham City, NJ."
}

variable "store_hours_message" {
  description = "Entry fulfillment message for the Store Hours page"
  type        = string
  default     = "We are open from 8 am to 5 pm Monday through Sunday."
}
