output "security_settings_id" {
  description = "Resource ID of the security settings (passed to the agent module)"
  value       = google_dialogflow_cx_security_settings.insurance_security.id
}