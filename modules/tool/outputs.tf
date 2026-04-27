output "policy_lookup_tool_id" {
  description = "Resource ID of the Policy Lookup Tool (reference in Playbook referenced_tools)"
  value       = google_dialogflow_cx_tool.policy_lookup.id
}