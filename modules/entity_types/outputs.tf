output "policy_type_entity_type_id" {
  description = "Resource ID of the policy_type entity type (used by intents and pages modules)"
  value       = google_dialogflow_cx_entity_type.policy_type.id
}

output "incident_type_entity_type_id" {
  description = "Resource ID of the incident_type entity type (used by intents and pages modules)"
  value       = google_dialogflow_cx_entity_type.incident_type.id
}

output "query_type_entity_type_id" {
  description = "Resource ID of the query_type entity type — mirrors the PolicyLookupTool enum"
  value       = google_dialogflow_cx_entity_type.query_type.id
}