# Page IDs consumed by the flows module to wire up transition routes
# in the default start flow via the REST API call.
# order_confirmation is not exported — it is only referenced internally by new_order.

output "store_location_page_id" {
  description = "Resource ID of the Store Location page"
  value       = google_dialogflow_cx_page.store_location.id
}

output "store_hours_page_id" {
  description = "Resource ID of the Store Hours page"
  value       = google_dialogflow_cx_page.store_hours.id
}

output "new_order_page_id" {
  description = "Resource ID of the New Order page"
  value       = google_dialogflow_cx_page.new_order.id
}
