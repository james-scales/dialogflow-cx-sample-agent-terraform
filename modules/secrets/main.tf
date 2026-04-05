#---------- Secret Manager API ----------#
resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

#---------- Secrets ----------#
# Creates each secret defined in var.secrets.
# Replication is scoped to a single user-managed region (matches Dialogflow agent location).
# prevent_destroy: Terraform will refuse to destroy secrets during terraform destroy,
# protecting runtime credentials from accidental deletion.
resource "google_secret_manager_secret" "secrets" {
  for_each  = var.secrets
  project   = var.project_id
  secret_id = each.key

  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }

  # Rotation schedule — sends a notification on next_rotation_time and every rotation_period after.
  # NOTE: Rotation notifications require a Pub/Sub topic; add a topics block and a subscriber
  # (e.g. Cloud Function) to automate the actual secret value rotation.
  dynamic "rotation" {
    for_each = var.next_rotation_time != null ? [1] : []
    content {
      rotation_period    = var.rotation_period
      next_rotation_time = var.next_rotation_time
    }
  }

  labels = {
    managed-by = "terraform"
    purpose    = each.value.purpose
  }

  depends_on = [google_project_service.secretmanager]

  lifecycle {
    prevent_destroy = true
  }
}

#---------- IAM: Runtime accessor bindings ----------#
# Grants secretAccessor to the specified IAM member for each secret.
# Skips secrets where accessor is an empty string (accessor is optional).
resource "google_secret_manager_secret_iam_member" "accessor" {
  for_each  = { for k, v in var.secrets : k => v if v.accessor != "" }
  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.accessor
}
