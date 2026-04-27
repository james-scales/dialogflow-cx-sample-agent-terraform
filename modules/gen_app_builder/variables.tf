variable "data_store_id" {
  description = "ID of the Discovery Engine data store"
  type        = string
  default     = "ins-chat-data-store"
}

variable "engine_id" {
  description = "ID of the Discovery Engine (last segment of the resource name)"
  type        = string
  default     = "ins-chat-engine"
}

variable "location" {
  description = "GCP region for the engine"
  type        = string
}

variable "display_name" {
  description = "Human-readable display name for the engine"
  type        = string
  default     = "Test Agent Builder Engine"
}

variable "default_language_code" {
  description = "Default language code for the chat engine (BCP-47)"
  type        = string
  default     = "en"
}

variable "time_zone" {
  description = "Time zone for the chat engine (IANA format)"
  type        = string
  default     = "America/Chicago"
}
