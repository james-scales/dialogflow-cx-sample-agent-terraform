output "engine_name" {
  description = "Full resource name of the Discovery Engine — pass to agent module as gen_app_builder_engine"
  value       = google_discovery_engine_search_engine.agent_engine.name
}
