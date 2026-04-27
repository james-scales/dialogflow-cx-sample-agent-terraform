output "accident_assistant_playbook_id" {
  description = "Resource ID of the Accident-Assistant playbook (consumed by the flows module)"
  value       = google_dialogflow_cx_playbook.accident_assistant.id
}