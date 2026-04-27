# Page IDs consumed by the flows module to wire up transition routes
# in the default start flow via the REST API call.

output "collect_policy_number_page_id" {
  description = "Resource ID of the Collect Policy Number page (payment flow entry)"
  value       = google_dialogflow_cx_page.collect_policy_number.id
}

output "collect_claim_details_page_id" {
  description = "Resource ID of the Collect Claim Details page (claim flow entry)"
  value       = google_dialogflow_cx_page.collect_claim_details.id
}

output "policy_inquiry_page_id" {
  description = "Resource ID of the Policy Inquiry page"
  value       = google_dialogflow_cx_page.policy_inquiry.id
}

output "accident_assistance_page_id" {
  description = "Resource ID of the Accident Assistance page (routes to Accident-Assistant Playbook — set target in console after apply)"
  value       = google_dialogflow_cx_page.accident_assistance.id
}