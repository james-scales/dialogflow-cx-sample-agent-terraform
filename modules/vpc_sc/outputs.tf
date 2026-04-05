output "access_policy_name" {
  description = "Full resource name of the Access Policy (format: 'accessPolicies/1234567890')"
  value       = local.access_policy_name
}

output "perimeter_name" {
  description = "Full resource name of the service perimeter"
  value       = google_access_context_manager_service_perimeter.dialogflow.name
}

output "perimeter_id" {
  description = "Terraform resource ID of the service perimeter"
  value       = google_access_context_manager_service_perimeter.dialogflow.id
}
