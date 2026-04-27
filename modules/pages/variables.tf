variable "agent_start_flow" {
  description = "Resource name of the agent's default start flow (passed from agent module output)"
  type        = string
}

variable "policy_type_entity_type_id" {
  description = "Resource ID of the policy_type entity type (passed from entity_types module output)"
  type        = string
}

variable "incident_type_entity_type_id" {
  description = "Resource ID of the incident_type entity type — passively captured on the Collect Claim Details page to provide incident context to adjusters"
  type        = string
}

variable "confirm_payment_message" {
  description = "Entry fulfillment message shown on the Confirm Payment page"
  type        = string
  default     = "Your current balance is due. Please confirm you would like to process this payment now."
}

variable "claim_confirmation_message" {
  description = "Entry fulfillment message shown on the Claim Confirmation page"
  type        = string
  default     = "Your claim has been submitted. A claims adjuster will contact you within 1-2 business days. Your claim reference number will be sent to your email on file."
}

variable "policy_lookup_webhook_id" {
  description = "Resource ID of the Policy Lookup Webhook — used to fetch the balance on the Collect Policy Number page"
  type        = string
}

