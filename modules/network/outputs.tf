output "psc_endpoint_ip" {
  description = "Private IP address of the PSC endpoint routing to Google APIs"
  value       = google_compute_global_address.psc_endpoint.address
}

output "psc_forwarding_rule_id" {
  description = "Resource ID of the PSC forwarding rule"
  value       = google_compute_global_forwarding_rule.psc_dialogflow.id
}

output "cloud_armor_policy_id" {
  description = "Resource ID of the Cloud Armor WAF security policy — attach to webhook backend services via backend_service.security_policy"
  value       = google_compute_security_policy.webhook_armor.id
}

output "mtls_trust_config_id" {
  description = "Resource ID of the Certificate Manager trust config"
  value       = google_certificate_manager_trust_config.webhook_mtls.id
}

output "server_tls_policy_id" {
  description = "Resource ID of the Server TLS Policy enforcing mTLS — attach to an HTTPS target proxy via server_tls_policy"
  value       = google_network_security_server_tls_policy.webhook_mtls.id
}
