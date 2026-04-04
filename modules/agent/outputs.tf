# These outputs are consumed by downstream modules:
#   - agent_id      → entity_types module, intents module
#   - agent_name    → flows module (used in REST API trigger)
#   - agent_start_flow → pages module (parent reference for all pages)

output "agent_id" {
  description = "Full resource ID of the Dialogflow CX agent (used as parent for intents and entity types)"
  value       = google_dialogflow_cx_agent.agent.id
}

output "agent_name" {
  description = "Full resource path of the Dialogflow CX agent (used in flows REST API call)"
  value       = google_dialogflow_cx_agent.agent.id
}

output "agent_start_flow" {
  description = "Resource name of the agent's default start flow (used as parent for pages)"
  value       = google_dialogflow_cx_agent.agent.start_flow
}
