variable "agent_id" {
  description = "Full resource ID of the Dialogflow CX agent"
  type        = string
}

variable "file_claim_intent_id" {
  description = "Resource ID of the claim.file intent"
  type        = string
}

variable "make_payment_intent_id" {
  description = "Resource ID of the payment.make intent"
  type        = string
}

variable "collect_claim_details_page_id" {
  description = "Resource ID of the Collect Claim Details page"
  type        = string
}

variable "collect_policy_number_page_id" {
  description = "Resource ID of the Collect Policy Number page"
  type        = string
}

variable "policy_inquiry_intent_id" {
  description = "Resource ID of the policy.inquiry intent"
  type        = string
}

variable "policy_inquiry_page_id" {
  description = "Resource ID of the Policy Inquiry page"
  type        = string
}