# google_dialogflow_cx_environment
# An environment pins specific flow versions so you can safely test a
# stable build while continuing to develop on the draft. This creates a
# "Development" environment that uses the v1.0.0 Default Start Flow.
#
# Test API calls against this environment by appending the environment
# name to the sessions URL:
# .../environments/ENVIRONMENT_ID/sessions/SESSION_ID:detectIntent

resource "google_dialogflow_cx_environment" "development" {
  parent       = var.agent_id
  display_name = "Development"
  description  = "Development environment — pinned to v1.0.0 of the Default Start Flow for stable testing."

  version_configs {
    # Pin the Default Start Flow to the versioned snapshot
    version = var.start_flow_version_id
  }
}