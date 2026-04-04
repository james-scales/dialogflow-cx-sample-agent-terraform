resource "null_resource" "default_start_flow" {
  # CREATE: PATCH the Default Start Flow to add intent-based transition routes.
  # A null_resource with local-exec is used because the Terraform Google provider
  # has no resource type for modifying the auto-generated Default Start Flow.
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      curl --location --request PATCH \
        "https://${self.triggers.LOCATION}-dialogflow.googleapis.com/v3/${self.triggers.AGENT}/flows/${self.triggers.DEFAULT_START_FLOW}?updateMask=transitionRoutes" \
        -H "Authorization: Bearer $(gcloud auth print-access-token --project=${self.triggers.PROJECT})" \
        -H "x-goog-user-project: ${self.triggers.PROJECT}" \
        -H "Content-Type: application/json" \
        --data-raw "{
          \"transitionRoutes\": [{
            \"intent\": \"${self.triggers.AGENT}/intents/${self.triggers.DEFAULT_WELCOME_INTENT}\",
            \"triggerFulfillment\": {
              \"messages\": [{
                \"text\": {
                  \"text\": [\"Hello, this is a shirt ordering virtual agent. How can I help you?\"]
                }
              }]
            }
          }, {
            \"intent\": \"${self.triggers.STORE_LOCATION_INTENT}\",
            \"targetPage\": \"${self.triggers.STORE_LOCATION_PAGE}\"
          }, {
            \"intent\": \"${self.triggers.STORE_HOURS_INTENT}\",
            \"targetPage\": \"${self.triggers.STORE_HOURS_PAGE}\"
          }, {
            \"intent\": \"${self.triggers.NEW_ORDER_INTENT}\",
            \"targetPage\": \"${self.triggers.NEW_ORDER_PAGE}\"
          }]
        }"
    EOT
  }

  triggers = {
    PROJECT  = var.project_id
    LOCATION = var.project_region
    # Full resource name: projects/{PROJECT}/locations/{LOCATION}/agents/{UUID}
    # Used directly in the URL path (v3/{AGENT}/flows/...) and as a prefix for intent names.
    AGENT = var.agent_name

    # Well-known nil UUIDs defined by the Dialogflow CX API — the same across all agents.
    DEFAULT_START_FLOW     = "00000000-0000-0000-0000-000000000000"
    DEFAULT_WELCOME_INTENT = "00000000-0000-0000-0000-000000000000"

    # Full resource names injected from upstream module outputs.
    STORE_LOCATION_INTENT = var.store_location_intent
    STORE_HOURS_INTENT    = var.store_hours_intent
    NEW_ORDER_INTENT      = var.new_order_intent

    STORE_LOCATION_PAGE = var.store_location_page
    STORE_HOURS_PAGE    = var.store_hours_page
    NEW_ORDER_PAGE      = var.new_order_page
  }

  # DESTROY: Remove the custom routes, restoring the flow to its default state.
  # This is required because the routes were added via REST (not a managed resource),
  # so Terraform cannot remove them automatically on destroy.
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      curl --location --request PATCH \
        "https://${self.triggers.LOCATION}-dialogflow.googleapis.com/v3/${self.triggers.AGENT}/flows/${self.triggers.DEFAULT_START_FLOW}?updateMask=transitionRoutes" \
        -H "Authorization: Bearer $(gcloud auth print-access-token --project=${self.triggers.PROJECT})" \
        -H "x-goog-user-project: ${self.triggers.PROJECT}" \
        -H "Content-Type: application/json" \
        --data-raw "{
          \"transitionRoutes\": [{
            \"intent\": \"${self.triggers.AGENT}/intents/${self.triggers.DEFAULT_WELCOME_INTENT}\",
            \"triggerFulfillment\": {
              \"messages\": [{
                \"text\": {
                  \"text\": [\"Hello, this is a shirt ordering virtual agent. How can I help you?\"]
                }
              }]
            }
          }]
        }"
    EOT
  }
}
