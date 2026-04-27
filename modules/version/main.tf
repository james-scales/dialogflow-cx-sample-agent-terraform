# google_dialogflow_cx_version
# Creates an immutable snapshot of the Default Start Flow at version 1.0.0.
# Environments reference flow versions — this version is what gets promoted
# to the Development environment.
#
# NOTE: Creating a version triggers agent training. The resource will show
# as LOADING in the console until training completes (usually 1-2 minutes).

resource "google_dialogflow_cx_version" "start_flow_v1" {
  parent       = var.agent_start_flow
  display_name = "1.0.0"
  description  = "Initial release — insurance virtual agent with payment flow, claim flow, and policy inquiry."

  timeouts {
    create = "10m"
  }
}