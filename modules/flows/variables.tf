variable "agent_id" {
  description = "Full resource ID of the Dialogflow CX agent (used as parent for the flow)"
  type        = string
}

variable "make_payment_intent" {
  description = "Resource ID of the payment.make intent"
  type        = string
}

variable "file_claim_intent" {
  description = "Resource ID of the claim.file intent"
  type        = string
}

variable "policy_inquiry_intent" {
  description = "Resource ID of the policy.inquiry intent"
  type        = string
}

variable "collect_policy_number_page" {
  description = "Resource ID of the Collect Policy Number page"
  type        = string
}

variable "collect_claim_details_page" {
  description = "Resource ID of the Collect Claim Details page"
  type        = string
}

variable "policy_inquiry_page" {
  description = "Resource ID of the Policy Inquiry page"
  type        = string
}

variable "accident_report_intent" {
  description = "Resource ID of the accident.report intent"
  type        = string
}

variable "accident_assistance_page" {
  description = "Resource ID of the Accident Assistance page — intermediate hop that hands off to the Playbook"
  type        = string
}
