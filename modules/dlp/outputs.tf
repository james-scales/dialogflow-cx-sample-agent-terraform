output "inspect_template_id" {
  description = "Resource ID of the DLP PII inspect template"
  value       = google_data_loss_prevention_inspect_template.pii.id
}

output "deidentify_template_id" {
  description = "Resource ID of the DLP PII deidentify (masking) template"
  value       = google_data_loss_prevention_deidentify_template.mask_pii.id
}

output "findings_dataset_id" {
  description = "BigQuery dataset ID where DLP scan findings are written"
  value       = google_bigquery_dataset.dlp_findings.dataset_id
}

output "job_trigger_id" {
  description = "Resource ID of the DLP GCS scan job trigger"
  value       = google_data_loss_prevention_job_trigger.gcs_scan.id
}
