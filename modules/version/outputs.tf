output "start_flow_version_id" {
  description = "Resource ID of the v1.0.0 Default Start Flow snapshot (used by environment module)"
  value       = google_dialogflow_cx_version.start_flow_v1.id
}