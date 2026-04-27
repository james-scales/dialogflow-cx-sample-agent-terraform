provider "google" {
  project     = var.project_id
  region      = var.project_region
  zone        = var.zone
  credentials = file("silken-impulse.json")
}

terraform {
  backend "gcs" {
    bucket = "scales-state-dev"
    prefix = "terraform/state/dialogflow-cx"
  }
  required_providers {
    google = ">= 7.26.0"
    null   = ">= 3.2.0"
  }

  required_version = ">= 1.2.0"
}

