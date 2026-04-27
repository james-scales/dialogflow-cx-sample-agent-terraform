variable "agent_id" {
  description = "Full resource ID of the Dialogflow CX agent"
  type        = string
}

variable "language_code" {
  description = "Language code for these generative settings (e.g. en)"
  type        = string
  default     = "en"
}