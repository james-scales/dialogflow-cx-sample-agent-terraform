output "notification_channel_id" {
  description = "Resource ID of the email notification channel used by all alert policies"
  value       = google_monitoring_notification_channel.email.name
}

output "audit_log_bucket_name" {
  description = "Name of the GCS bucket storing exported audit logs"
  value       = google_storage_bucket.audit_logs.name
}

output "audit_sink_writer_identity" {
  description = "Service account identity of the log sink — used to grant additional bucket permissions if needed"
  value       = google_logging_project_sink.audit_sink.writer_identity
}

output "alert_policy_ids" {
  description = "Map of alert policy display names to their resource IDs"
  value = {
    unauthorized_iam_changes = google_monitoring_alert_policy.unauthorized_iam_changes.id
    api_enablement           = google_monitoring_alert_policy.api_enablement.id
    webhook_failures         = google_monitoring_alert_policy.webhook_failures.id
    detectintent_errors      = google_monitoring_alert_policy.detectintent_errors.id
    agent_export_import      = google_monitoring_alert_policy.agent_export_import.id
    certificate_anomalies    = google_monitoring_alert_policy.certificate_anomalies.id
  }
}
