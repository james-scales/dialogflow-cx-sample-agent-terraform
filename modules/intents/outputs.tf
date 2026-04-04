# All intent IDs are consumed by the flows module to wire up transition routes
# in the default start flow via the REST API call.

output "store_location_intent_id" {
  description = "Resource ID of the store.location intent"
  value       = google_dialogflow_cx_intent.store_location.id
}

output "store_hours_intent_id" {
  description = "Resource ID of the store.hours intent"
  value       = google_dialogflow_cx_intent.store_hours.id
}

output "new_order_intent_id" {
  description = "Resource ID of the order.new intent"
  value       = google_dialogflow_cx_intent.order_new.id
}
