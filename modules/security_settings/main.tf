# google_dialogflow_cx_security_settings
# Location-level resource — applies PII redaction and data retention rules.
# Must be in the same location as the agent. Attach to the agent via
# the agent resource's security_settings field.

resource "google_dialogflow_cx_security_settings" "insurance_security" {
  display_name = var.display_name
  location     = var.location
  project      = var.project_id

  # Redact PII (policy numbers, names, DOBs) from disk storage
  redaction_strategy = "REDACT_WITH_SERVICE"
  redaction_scope    = "REDACT_DISK_STORAGE"

  # Retain conversation turns for 30 days with PII masked —
  # supports quality review and compliance audits without exposing raw PII.
  # DLP (REDACT_WITH_SERVICE) identifies and masks PII fields only;
  # the surrounding conversation context is preserved for the retention window.
  retention_window_days = 30

  insights_export_settings {
    enable_insights_export = true
  }
}