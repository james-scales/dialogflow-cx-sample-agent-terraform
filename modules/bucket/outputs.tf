output "bucket_url" {
  description = "The base URL of the GCS bucket (used for audio export URI)"
  value       = google_storage_bucket.bucket.url
}

output "bucket_name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.bucket.name
}
