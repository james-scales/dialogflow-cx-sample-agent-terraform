# google_dialogflow_cx_webhook
# Webhooks let Dialogflow call an external HTTPS endpoint at runtime to fetch
# live data or trigger backend actions. This webhook calls a demo policy
# lookup API — replace the URI with your real Cloud Run / Cloud Function URL.

resource "google_dialogflow_cx_webhook" "policy_lookup" {
  parent       = var.agent_id
  display_name = "Policy-Lookup-Webhook"

  # Timeout — insurance lookups may require a database query; 10s is generous
  timeout = "10s"

  generic_web_service {
    uri = var.webhook_uri

    # Pass the GCP project as a header so the backend can validate the caller
    request_headers = {
      "x-insurance-source" = "dialogflow-cx-agent"
    }

    # Use Dialogflow's service agent identity — no stored credentials needed
    service_agent_auth = "ID_TOKEN"
  }

  lifecycle {
    ignore_changes = [generic_web_service[0].webhook_type, enable_stackdriver_logging]
  }
}