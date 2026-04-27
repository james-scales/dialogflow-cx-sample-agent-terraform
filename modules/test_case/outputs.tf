output "file_claim_test_case_id" {
  description = "Resource ID of the file-a-claim happy path test case"
  value       = google_dialogflow_cx_test_case.file_claim_happy_path.id
}

output "make_payment_test_case_id" {
  description = "Resource ID of the make-a-payment happy path test case"
  value       = google_dialogflow_cx_test_case.make_payment_happy_path.id
}

output "policy_inquiry_test_case_id" {
  description = "Resource ID of the policy inquiry happy path test case"
  value       = google_dialogflow_cx_test_case.policy_inquiry_happy_path.id
}

output "no_match_fallback_test_case_id" {
  description = "Resource ID of the no-match fallback reprompt test case"
  value       = google_dialogflow_cx_test_case.no_match_fallback.id
}

output "file_claim_multi_turn_test_case_id" {
  description = "Resource ID of the multi-turn claim form fill test case"
  value       = google_dialogflow_cx_test_case.file_claim_multi_turn.id
}