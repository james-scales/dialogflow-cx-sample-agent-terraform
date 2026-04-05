#---------- Required APIs ----------#
resource "google_project_service" "monitoring" {
  project            = var.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

#---------- Audit Logging ----------#
# Enables Admin Activity, Data Read, and Data Write audit logs for all GCP services
# including Dialogflow CX, Cloud KMS, and Secret Manager.
# NOTE: google_project_iam_audit_config is authoritative for the specified service.
# Using "allServices" provides comprehensive coverage per the security standard.
resource "google_project_iam_audit_config" "all_services" {
  project = var.project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

#---------- Audit Log Sink ----------#
# Exports all Cloud Audit Logs to a dedicated GCS bucket for long-term retention and SIEM ingestion.
resource "google_storage_bucket" "audit_logs" {
  project                     = var.project_id
  name                        = var.audit_log_bucket_name
  location                    = var.location
  uniform_bucket_level_access = true

  retention_policy {
    retention_period = var.audit_log_retention_days * 86400
  }

  lifecycle_rule {
    condition {
      age = var.audit_log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.storage]
}

resource "google_logging_project_sink" "audit_sink" {
  project                = var.project_id
  name                   = "dialogflow-audit-log-sink"
  description            = "Exports Cloud Audit Logs (Admin + Data Access) to GCS for long-term retention"
  destination            = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"
  filter                 = "protoPayload.@type=\"type.googleapis.com/google.cloud.audit.AuditLog\""
  unique_writer_identity = true

  depends_on = [google_project_service.logging]
}

# Grant the sink's auto-created service account write access to the audit bucket
resource "google_storage_bucket_iam_member" "audit_sink_writer" {
  bucket = google_storage_bucket.audit_logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.audit_sink.writer_identity
}

#---------- Notification Channel ----------#
resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Dialogflow Security Alerts — Email"
  type         = "email"

  labels = {
    email_address = var.alert_email_address
  }

  depends_on = [google_project_service.monitoring]
}

#==========================================================================
# LOG-BASED METRICS
# Each metric counts matching log entries. Alert policies (below) fire when
# any metric count exceeds its threshold within the evaluation window.
#==========================================================================

#---------- Metric 1: Unauthorized IAM changes ----------#
# Fires when a primitive role (Editor/Owner) is granted — violates DF006.
resource "google_logging_metric" "unauthorized_iam_changes" {
  project = var.project_id
  name    = "dialogflow/unauthorized-iam-changes"

  filter = <<-EOT
    protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
    AND protoPayload.methodName="SetIamPolicy"
    AND (
      protoPayload.serviceData.policyDelta.bindingDeltas.role="roles/editor"
      OR protoPayload.serviceData.policyDelta.bindingDeltas.role="roles/owner"
    )
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Unauthorized IAM Role Grants"
  }

  depends_on = [google_project_service.logging]
}

#---------- Metric 2: API enablement attempts ----------#
# Tracks attempts to enable new GCP APIs — may indicate unauthorized infrastructure changes.
resource "google_logging_metric" "api_enablement" {
  project = var.project_id
  name    = "dialogflow/api-enablement-attempts"

  filter = <<-EOT
    protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
    AND protoPayload.methodName="google.api.serviceusage.v1.ServiceUsage.EnableService"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "GCP API Enablement Attempts"
  }

  depends_on = [google_project_service.logging]
}

#---------- Metric 3: Webhook failures ----------#
# Counts Dialogflow CX webhook calls that returned a non-success status.
# Sustained failures may indicate mTLS misconfiguration or backend outage.
resource "google_logging_metric" "webhook_failures" {
  project = var.project_id
  name    = "dialogflow/webhook-failures"

  filter = <<-EOT
    resource.type="dialogflow_cx_agent"
    AND severity>=ERROR
    AND jsonPayload.queryResult.webhookStatuses.code!="0"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Dialogflow CX Webhook Failures"
  }

  depends_on = [google_project_service.logging]
}

#---------- Metric 4: detectIntent errors ----------#
# Counts agent-level errors during detectIntent calls — covers timeouts and backend faults.
resource "google_logging_metric" "detectintent_errors" {
  project = var.project_id
  name    = "dialogflow/detectintent-errors"

  filter = <<-EOT
    resource.type="dialogflow_cx_agent"
    AND severity=ERROR
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Dialogflow CX detectIntent Errors"
  }

  depends_on = [google_project_service.logging]
}

#---------- Metric 5: Agent export/import events ----------#
# Unexpected agent exports or imports may indicate data exfiltration or unauthorized changes.
resource "google_logging_metric" "agent_export_import" {
  project = var.project_id
  name    = "dialogflow/agent-export-import"

  filter = <<-EOT
    protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
    AND protoPayload.serviceName="dialogflow.googleapis.com"
    AND (
      protoPayload.methodName=~"ExportAgent"
      OR protoPayload.methodName=~"ImportAgent"
      OR protoPayload.methodName=~"RestoreAgent"
    )
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Dialogflow CX Agent Export/Import Events"
  }

  depends_on = [google_project_service.logging]
}

#---------- Metric 6: Suspicious certificate activity ----------#
# Tracks anomalous Certificate Manager events — unexpected cert creation/deletion
# could signal mTLS misconfiguration or credential rotation issues.
resource "google_logging_metric" "certificate_anomalies" {
  project = var.project_id
  name    = "dialogflow/certificate-anomalies"

  filter = <<-EOT
    protoPayload.@type="type.googleapis.com/google.cloud.audit.AuditLog"
    AND protoPayload.serviceName="certificatemanager.googleapis.com"
    AND severity>=WARNING
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Certificate Manager Anomalies"
  }

  depends_on = [google_project_service.logging]
}

#==========================================================================
# ALERT POLICIES
# All alerts notify via the email channel. threshold_value = 0 means fire on
# any occurrence. duration = "0s" fires immediately (no sustained-for window).
#==========================================================================

locals {
  # Shared aggregation config used by all log-based metric alert conditions
  log_metric_aggregation = {
    alignment_period     = "300s"
    per_series_aligner   = "ALIGN_COUNT"
    cross_series_reducer = "REDUCE_SUM"
    group_by_fields      = ["resource.labels.project_id"]
  }
}

#---------- Alert 1: Unauthorized IAM change ----------#
resource "google_monitoring_alert_policy" "unauthorized_iam_changes" {
  project      = var.project_id
  display_name = "[Dialogflow Security] Unauthorized IAM Role Grant Detected"
  combiner     = "OR"
  severity     = "CRITICAL"

  conditions {
    display_name = "Primitive role (Editor/Owner) granted"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.unauthorized_iam_changes.name}\" AND resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = local.log_metric_aggregation.alignment_period
        per_series_aligner   = local.log_metric_aggregation.per_series_aligner
        cross_series_reducer = local.log_metric_aggregation.cross_series_reducer
        group_by_fields      = local.log_metric_aggregation.group_by_fields
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "A primitive IAM role (Editor or Owner) was granted on this project. This violates the least-privilege security standard (DF006). Investigate immediately and revoke if unauthorized."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}

#---------- Alert 2: API enablement ----------#
resource "google_monitoring_alert_policy" "api_enablement" {
  project      = var.project_id
  display_name = "[Dialogflow Security] GCP API Enabled"
  combiner     = "OR"
  severity     = "WARNING"

  conditions {
    display_name = "New API enabled on project"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.api_enablement.name}\" AND resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = local.log_metric_aggregation.alignment_period
        per_series_aligner   = local.log_metric_aggregation.per_series_aligner
        cross_series_reducer = local.log_metric_aggregation.cross_series_reducer
        group_by_fields      = local.log_metric_aggregation.group_by_fields
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "A GCP API was enabled on this project. Verify this was an authorized change through the CI/CD pipeline and not performed manually."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}

#---------- Alert 3: Webhook failures ----------#
resource "google_monitoring_alert_policy" "webhook_failures" {
  project      = var.project_id
  display_name = "[Dialogflow Ops] Webhook Failures Detected"
  combiner     = "OR"
  severity     = "ERROR"

  conditions {
    display_name = "Webhook returning non-success status"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.webhook_failures.name}\" AND resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.webhook_failure_threshold
      duration        = "60s"

      aggregations {
        alignment_period     = local.log_metric_aggregation.alignment_period
        per_series_aligner   = local.log_metric_aggregation.per_series_aligner
        cross_series_reducer = local.log_metric_aggregation.cross_series_reducer
        group_by_fields      = local.log_metric_aggregation.group_by_fields
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "Dialogflow CX webhook calls are failing. Check mTLS certificate validity, webhook backend health, and network connectivity through PSC."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}

#---------- Alert 4: detectIntent error rate ----------#
resource "google_monitoring_alert_policy" "detectintent_errors" {
  project      = var.project_id
  display_name = "[Dialogflow Ops] High detectIntent Error Rate"
  combiner     = "OR"
  severity     = "ERROR"

  conditions {
    display_name = "Sustained detectIntent errors"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.detectintent_errors.name}\" AND resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = var.detectintent_error_threshold
      duration        = "300s"

      aggregations {
        alignment_period     = local.log_metric_aggregation.alignment_period
        per_series_aligner   = local.log_metric_aggregation.per_series_aligner
        cross_series_reducer = local.log_metric_aggregation.cross_series_reducer
        group_by_fields      = local.log_metric_aggregation.group_by_fields
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "The Dialogflow CX agent is experiencing elevated error rates on detectIntent calls. Check agent configuration, quota limits, and backend dependencies."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}

#---------- Alert 5: Agent export/import ----------#
resource "google_monitoring_alert_policy" "agent_export_import" {
  project      = var.project_id
  display_name = "[Dialogflow Security] Agent Export/Import Detected"
  combiner     = "OR"
  severity     = "WARNING"

  conditions {
    display_name = "Agent exported, imported, or restored"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.agent_export_import.name}\" AND resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = local.log_metric_aggregation.alignment_period
        per_series_aligner   = local.log_metric_aggregation.per_series_aligner
        cross_series_reducer = local.log_metric_aggregation.cross_series_reducer
        group_by_fields      = local.log_metric_aggregation.group_by_fields
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "A Dialogflow CX agent was exported, imported, or restored. Verify this was an authorized CI/CD operation. Unexpected exports may indicate data exfiltration."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}

#---------- Alert 6: Certificate anomalies ----------#
resource "google_monitoring_alert_policy" "certificate_anomalies" {
  project      = var.project_id
  display_name = "[Dialogflow Security] Certificate Manager Anomaly"
  combiner     = "OR"
  severity     = "WARNING"

  conditions {
    display_name = "Unexpected certificate activity"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.certificate_anomalies.name}\" AND resource.type=\"global\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = local.log_metric_aggregation.alignment_period
        per_series_aligner   = local.log_metric_aggregation.per_series_aligner
        cross_series_reducer = local.log_metric_aggregation.cross_series_reducer
        group_by_fields      = local.log_metric_aggregation.group_by_fields
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "An anomalous event was detected in Certificate Manager. Check for unexpected certificate creation, deletion, or rotation events that could affect mTLS enforcement."
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "604800s"
  }
}
