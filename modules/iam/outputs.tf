output "agent_builder_role_id" {
  description = "Resource ID of the Agent Builder custom IAM role"
  value       = google_project_iam_custom_role.agent_builder.id
}

output "webhook_developer_role_id" {
  description = "Resource ID of the Webhook Developer custom IAM role"
  value       = google_project_iam_custom_role.webhook_developer.id
}

output "cicd_automation_role_id" {
  description = "Resource ID of the CI/CD Automation custom IAM role"
  value       = google_project_iam_custom_role.cicd_automation.id
}
