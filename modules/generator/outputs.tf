output "claims_empathy_generator_id" {
  description = "Resource ID of the Claims Empathy Generator (reference in Playbook instructions)"
  value       = google_dialogflow_cx_generator.claims_empathy.id
}