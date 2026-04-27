resource "google_storage_bucket" "bucket" {
  name                        = var.bucket_name
  location                    = var.bucket_location
  uniform_bucket_level_access = true
  force_destroy               = true

  public_access_prevention = "enforced"
  versioning {
    enabled = true
  }

}
