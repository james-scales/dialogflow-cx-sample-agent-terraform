output "secret_ids" {
  description = "Map of secret_id keys to their full GCP resource names"
  value       = { for k, v in google_secret_manager_secret.secrets : k => v.id }
}

output "webhook_auth_secret_id" {
  description = "Full resource ID of the webhook authentication token secret"
  value       = try(google_secret_manager_secret.secrets["dialogflow-webhook-auth-token"].id, null)
}

output "github_token_secret_id" {
  description = "Full resource ID of the GitHub integration token secret"
  value       = try(google_secret_manager_secret.secrets["dialogflow-github-token"].id, null)
}
