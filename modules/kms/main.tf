#---------- Cloud KMS Key Ring ----------#
# Key rings are permanent in GCP — they cannot be deleted once created.
# prevent_destroy ensures Terraform also refuses to destroy this resource,
# causing terraform destroy to exit with a guard error rather than deleting it.
resource "google_kms_key_ring" "dialogflow" {
  project  = var.project_id
  name     = var.key_ring_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

#---------- CMEK Crypto Key ----------#
# AES-256 symmetric key for encrypting Dialogflow CX agent data at rest.
# rotation_period: auto-rotates every 90 days — new key versions are created automatically.
# GCP enforces a minimum 24-hour scheduled deletion window on crypto keys regardless of Terraform.
# prevent_destroy: Terraform will refuse to destroy this key during terraform destroy.
resource "google_kms_crypto_key" "dialogflow_cmek" {
  name            = var.crypto_key_name
  key_ring        = google_kms_key_ring.dialogflow.id
  rotation_period = var.rotation_period
  purpose         = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = var.protection_level
  }

  lifecycle {
    prevent_destroy = true
  }
}

#---------- Dialogflow Service Agent: CMEK access ----------#
# The Dialogflow Service Agent requires CryptoKey Encrypter/Decrypter to use CMEK.
# This binding must exist before the agent location setting is configured in the console.
# Service Agent email format: service-{PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com
resource "google_kms_crypto_key_iam_member" "dialogflow_sa_encrypter" {
  crypto_key_id = google_kms_crypto_key.dialogflow_cmek.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${var.project_number}@gcp-sa-dialogflow.iam.gserviceaccount.com"
}
