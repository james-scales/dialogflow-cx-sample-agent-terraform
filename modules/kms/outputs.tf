output "key_ring_id" {
  description = "Resource ID of the KMS key ring"
  value       = google_kms_key_ring.dialogflow.id
}

output "crypto_key_id" {
  description = "Full resource ID of the Dialogflow CMEK crypto key"
  value       = google_kms_crypto_key.dialogflow_cmek.id
}

output "crypto_key_name" {
  description = "Short name of the CMEK crypto key (used when selecting the key in Dialogflow location settings)"
  value       = google_kms_crypto_key.dialogflow_cmek.name
}
