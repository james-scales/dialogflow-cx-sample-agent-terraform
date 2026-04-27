output "policy_lookup_webhook_id" {
  description = "Resource ID of the Policy Lookup Webhook"
  value       = google_dialogflow_cx_webhook.policy_lookup.id
}