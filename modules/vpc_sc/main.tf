#---------- Access Context Manager API ----------#
# Enabling at the project level — the actual Access Policy is an org-level resource.
resource "google_project_service" "access_context_manager" {
  project            = var.project_id
  service            = "accesscontextmanager.googleapis.com"
  disable_on_destroy = false
}

#---------- Access Policy ----------#
# An organization can only have ONE Access Policy. If one already exists, provide its
# name via var.existing_access_policy_name and this resource will be skipped.
# Format of existing name: "accessPolicies/1234567890"
resource "google_access_context_manager_access_policy" "policy" {
  count  = var.existing_access_policy_name == null ? 1 : 0
  parent = "organizations/${var.org_id}"
  title  = var.access_policy_title

  depends_on = [google_project_service.access_context_manager]
}

locals {
  # Resolves to the existing policy name if provided, otherwise uses the newly created one.
  access_policy_name = var.existing_access_policy_name != null ? var.existing_access_policy_name : google_access_context_manager_access_policy.policy[0].name
  # Strips "accessPolicies/" prefix to get the numeric ID used in resource names.
  access_policy_id   = replace(local.access_policy_name, "accessPolicies/", "")
}

#---------- Service Perimeter ----------#
# Wraps the Dialogflow project in a VPC-SC boundary at the org level.
# Restricts dialogflow.googleapis.com, secretmanager.googleapis.com, and cloudkms.googleapis.com
# so that only authorized identities can call these APIs, mitigating data exfiltration risk.
#
# IMPORTANT: Applying a perimeter in ENFORCED mode will block all API access not explicitly
# permitted by ingress/egress rules. Test with dry_run = true first (use the
# google_access_context_manager_service_perimeter resource's status/spec blocks).
resource "google_access_context_manager_service_perimeter" "dialogflow" {
  parent = "accessPolicies/${local.access_policy_id}"
  name   = "accessPolicies/${local.access_policy_id}/servicePerimeters/${var.perimeter_name}"
  title  = var.perimeter_title

  status {
    # Projects protected by this perimeter (format: "projects/{project_number}")
    resources = ["projects/${var.project_number}"]

    # APIs restricted within the perimeter — calls to these services from outside
    # the perimeter must be explicitly permitted via ingress rules below.
    restricted_services = [
      "dialogflow.googleapis.com",
      "secretmanager.googleapis.com",
      "cloudkms.googleapis.com",
    ]

    #---------- Ingress rules ----------#
    # Allows var.ingress_identities (groups, service accounts) to call Dialogflow APIs
    # from outside the perimeter. Optionally scoped to a named access level (e.g. corporate network).
    dynamic "ingress_policies" {
      for_each = length(var.ingress_identities) > 0 ? [1] : []
      content {
        ingress_from {
          identities = var.ingress_identities

          # If an access level is provided, requests must also satisfy it (e.g. originate from
          # a trusted network or device). Leave var.ingress_access_level null to allow any source.
          dynamic "sources" {
            for_each = var.ingress_access_level != null ? [var.ingress_access_level] : []
            content {
              access_level = sources.value
            }
          }
        }

        ingress_to {
          resources = ["*"]
          operations {
            service_name = "dialogflow.googleapis.com"
            method_selectors {
              method = "*"
            }
          }
        }
      }
    }

    #---------- Egress rules ----------#
    # Allows the Dialogflow service agent and CI/CD accounts to call Cloud KMS and
    # Secret Manager from within the perimeter (required for CMEK and secret access).
    egress_policies {
      egress_from {
        identities = concat(
          ["serviceAccount:service-${var.project_number}@gcp-sa-dialogflow.iam.gserviceaccount.com"],
          var.egress_identities
        )
      }

      egress_to {
        resources = ["*"]

        # Cloud KMS — required for CMEK key operations
        operations {
          service_name = "cloudkms.googleapis.com"
          method_selectors {
            method = "*"
          }
        }

        # Secret Manager — required for webhook token and GitHub token access
        operations {
          service_name = "secretmanager.googleapis.com"
          method_selectors {
            method = "*"
          }
        }
      }
    }
  }

  depends_on = [google_project_service.access_context_manager]
}
