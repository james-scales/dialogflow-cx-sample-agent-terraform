variable "project_id" {
  description = "GCP project ID (passed from root var.project_id)"
  type        = string
}

variable "project_region" {
  description = "GCP region (passed from root var.project_region)"
  type        = string
}

variable "agent_name" {
  description = "Dialogflow CX agent resource name (passed from agent module output)"
  type        = string
}

variable "store_location_intent" {
  description = "Resource ID of the store.location intent"
  type        = string
}

variable "store_hours_intent" {
  description = "Resource ID of the store.hours intent"
  type        = string
}

variable "new_order_intent" {
  description = "Resource ID of the order.new intent"
  type        = string
}

variable "store_location_page" {
  description = "Resource ID of the Store Location page"
  type        = string
}

variable "store_hours_page" {
  description = "Resource ID of the Store Hours page"
  type        = string
}

variable "new_order_page" {
  description = "Resource ID of the New Order page"
  type        = string
}
