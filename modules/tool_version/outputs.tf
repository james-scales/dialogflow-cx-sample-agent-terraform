output "policy_lookup_tool_version_id" {
  description = "Resource ID of the v1.0.0 Policy Lookup Tool snapshot"
  value       = google_dialogflow_cx_tool_version.policy_lookup_v1.id
}