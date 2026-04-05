#---------- IAM Recommender API ----------#
# Enables ML-based least-privilege suggestions for this project.
resource "google_project_service" "recommender" {
  project            = var.project_id
  service            = "recommender.googleapis.com"
  disable_on_destroy = false
}

#---------- Custom Role: Agent Builder ----------#
# Scoped to agent, flow, page, intent, and entity type CRUD only.
# Explicitly excludes primitive Editor/Owner permissions (security standard: DF006).
resource "google_project_iam_custom_role" "agent_builder" {
  project     = var.project_id
  role_id     = "dialogflowAgentBuilder"
  title       = "Dialogflow CX Agent Builder"
  description = "Least-privilege role for building and editing Dialogflow CX agents. No primitive Editor/Owner permissions."
  permissions = [
    "dialogflow.agents.get",
    "dialogflow.agents.update",
    "dialogflow.agents.export",
    "dialogflow.agents.import",
    "dialogflow.flows.get",
    "dialogflow.flows.create",
    "dialogflow.flows.update",
    "dialogflow.flows.delete",
    "dialogflow.pages.get",
    "dialogflow.pages.create",
    "dialogflow.pages.update",
    "dialogflow.pages.delete",
    "dialogflow.intents.get",
    "dialogflow.intents.create",
    "dialogflow.intents.update",
    "dialogflow.intents.delete",
    "dialogflow.entityTypes.get",
    "dialogflow.entityTypes.create",
    "dialogflow.entityTypes.update",
    "dialogflow.entityTypes.delete",
    "dialogflow.sessions.detectIntent",
    "dialogflow.sessions.streamingDetectIntent",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

#---------- Custom Role: Webhook Developer ----------#
# Grants webhook CRUD and Secret Manager read access for runtime secrets.
# Certificate Manager read access supports mTLS validation workflows.
resource "google_project_iam_custom_role" "webhook_developer" {
  project     = var.project_id
  role_id     = "dialogflowWebhookDeveloper"
  title       = "Dialogflow CX Webhook Developer"
  description = "Least-privilege role for managing Dialogflow CX webhooks and reading webhook secrets via Secret Manager."
  permissions = [
    "dialogflow.webhooks.get",
    "dialogflow.webhooks.create",
    "dialogflow.webhooks.update",
    "dialogflow.webhooks.delete",
    "dialogflow.flows.get",
    "secretmanager.secrets.get",
    "secretmanager.versions.get",
    "secretmanager.versions.access",
    "certificatemanager.certs.get",
    "certificatemanager.certs.list",
  ]
}

#---------- Custom Role: CI/CD Automation ----------#
# Scoped to full Dialogflow CX resource lifecycle and state bucket access.
# Used by CI/CD service accounts running Terraform — no console or human-access permissions.
resource "google_project_iam_custom_role" "cicd_automation" {
  project     = var.project_id
  role_id     = "dialogflowCicdAutomation"
  title       = "Dialogflow CX CI/CD Automation"
  description = "Least-privilege role for CI/CD service accounts deploying Dialogflow CX resources via Terraform."
  permissions = [
    "dialogflow.agents.get",
    "dialogflow.agents.create",
    "dialogflow.agents.update",
    "dialogflow.agents.delete",
    "dialogflow.agents.export",
    "dialogflow.agents.import",
    "dialogflow.flows.get",
    "dialogflow.flows.create",
    "dialogflow.flows.update",
    "dialogflow.flows.delete",
    "dialogflow.pages.get",
    "dialogflow.pages.create",
    "dialogflow.pages.update",
    "dialogflow.pages.delete",
    "dialogflow.intents.get",
    "dialogflow.intents.create",
    "dialogflow.intents.update",
    "dialogflow.intents.delete",
    "dialogflow.entityTypes.get",
    "dialogflow.entityTypes.create",
    "dialogflow.entityTypes.update",
    "dialogflow.entityTypes.delete",
    "dialogflow.webhooks.get",
    "dialogflow.webhooks.create",
    "dialogflow.webhooks.update",
    "dialogflow.webhooks.delete",
    "storage.objects.get",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.buckets.get",
    "iam.serviceAccounts.actAs",
  ]
}

#---------- IAM Bindings (non-authoritative) ----------#
# Using google_project_iam_member (additive) to avoid overwriting bindings
# managed outside this module. Group-based access enforced per security standard.

resource "google_project_iam_member" "agent_builder_group" {
  project = var.project_id
  role    = google_project_iam_custom_role.agent_builder.id
  member  = "group:${var.agent_builder_group}"
}

resource "google_project_iam_member" "webhook_developer_group" {
  project = var.project_id
  role    = google_project_iam_custom_role.webhook_developer.id
  member  = "group:${var.webhook_developer_group}"
}

resource "google_project_iam_member" "cicd_service_account" {
  project = var.project_id
  role    = google_project_iam_custom_role.cicd_automation.id
  member  = "serviceAccount:${var.cicd_service_account_email}"
}
