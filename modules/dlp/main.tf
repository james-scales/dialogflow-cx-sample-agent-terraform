#---------- Required APIs ----------#
resource "google_project_service" "dlp" {
  project            = var.project_id
  service            = "dlp.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery" {
  project            = var.project_id
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

#---------- Inspect Template ----------#
# Defines which PII info types to detect in Dialogflow training phrases and agent exports.
# min_likelihood = LIKELY reduces false positives while still catching clear PII.
resource "google_data_loss_prevention_inspect_template" "pii" {
  parent       = "projects/${var.project_id}/locations/${var.location}"
  display_name = "Dialogflow CX PII Inspector"
  description  = "Scans Dialogflow CX training phrases and agent exports for PII per security standard"

  inspect_config {
    info_types { name = "EMAIL_ADDRESS" }
    info_types { name = "PHONE_NUMBER" }
    info_types { name = "PERSON_NAME" }
    info_types { name = "DATE_OF_BIRTH" }
    info_types { name = "US_SOCIAL_SECURITY_NUMBER" }
    info_types { name = "CREDIT_CARD_NUMBER" }
    info_types { name = "US_PASSPORT" }
    info_types { name = "IP_ADDRESS" }
    info_types { name = "STREET_ADDRESS" }

    # Only surface findings with high confidence to reduce noise
    min_likelihood = "LIKELY"

    limits {
      max_findings_per_request = 100
    }

    include_quote = true
  }

  depends_on = [google_project_service.dlp]
}

#---------- DeIdentify Template ----------#
# Transforms detected PII by replacing it with its info type name (e.g. [EMAIL_ADDRESS]).
# This is applied when masking agent exports before storing or sharing them.
resource "google_data_loss_prevention_deidentify_template" "mask_pii" {
  parent       = "projects/${var.project_id}/locations/${var.location}"
  display_name = "Dialogflow CX PII Masking"
  description  = "Replaces detected PII with info type token (e.g. [EMAIL_ADDRESS]) to reduce exposure risk"

  deidentify_config {
    info_type_transformations {
      transformations {
        # Applies to all info types defined in the inspect template
        primitive_transformation {
          replace_with_info_type_config {}
        }
      }
    }
  }

  depends_on = [google_project_service.dlp]
}

#---------- BigQuery Dataset: DLP Findings ----------#
# Stores scan findings for audit and analysis. Retention enforced via table expiration.
resource "google_bigquery_dataset" "dlp_findings" {
  project                    = var.project_id
  dataset_id                 = var.findings_dataset_id
  location                   = var.location
  description                = "DLP scan findings from Dialogflow CX agent exports and training data"
  default_table_expiration_ms = var.findings_table_expiration_ms

  labels = {
    managed-by = "terraform"
    purpose    = "dlp-findings"
  }

  depends_on = [google_project_service.bigquery]
}

#---------- DLP Job Trigger ----------#
# Runs a scheduled PII scan against the Dialogflow CX GCS bucket (agent exports + audio).
# Findings are written to BigQuery for audit review.
# Trigger runs daily — adjust recurrence_period_duration in tfvars if needed.
resource "google_data_loss_prevention_job_trigger" "gcs_scan" {
  parent       = "projects/${var.project_id}/locations/${var.location}"
  display_name = "Dialogflow CX GCS PII Scan"
  description  = "Daily DLP scan of Dialogflow CX agent exports and audio files for PII"
  status       = "HEALTHY"

  triggers {
    schedule {
      recurrence_period_duration = var.scan_recurrence_period
    }
  }

  inspect_job {
    inspect_template_name = google_data_loss_prevention_inspect_template.pii.id

    storage_config {
      cloud_storage_options {
        file_set {
          url = "gs://${var.gcs_bucket_name}/**"
        }
        # Scan both plaintext and binary (covers JSON exports and audio files)
        file_types    = ["TEXT_FILE", "BINARY_FILE"]
        bytes_limit_per_file = var.bytes_limit_per_file
      }
    }

    # Save findings to BigQuery for audit trail
    actions {
      save_findings {
        output_config {
          table {
            project_id = var.project_id
            dataset_id = google_bigquery_dataset.dlp_findings.dataset_id
            table_id   = "gcs_scan_findings"
          }
        }
      }
    }

    # Publish a summary to Pub/Sub if a topic is configured (optional — enables alerting pipelines)
    dynamic "actions" {
      for_each = var.findings_pubsub_topic != null ? [var.findings_pubsub_topic] : []
      content {
        pub_sub {
          topic = actions.value
        }
      }
    }
  }

  depends_on = [
    google_data_loss_prevention_inspect_template.pii,
    google_bigquery_dataset.dlp_findings,
  ]
}
