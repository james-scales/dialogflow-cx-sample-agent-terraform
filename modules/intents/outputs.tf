# All intent IDs are consumed by the flows module to wire up transition routes
# in the default start flow via the REST API call.

output "make_payment_intent_id" {
  description = "Resource ID of the payment.make intent"
  value       = google_dialogflow_cx_intent.make_payment.id
}

output "file_claim_intent_id" {
  description = "Resource ID of the claim.file intent"
  value       = google_dialogflow_cx_intent.file_claim.id
}

output "policy_inquiry_intent_id" {
  description = "Resource ID of the policy.inquiry intent"
  value       = google_dialogflow_cx_intent.policy_inquiry.id
}

output "accident_report_intent_id" {
  description = "Resource ID of the accident.report intent — routes to the Accident-Assistant Playbook"
  value       = google_dialogflow_cx_intent.accident_report.id
}