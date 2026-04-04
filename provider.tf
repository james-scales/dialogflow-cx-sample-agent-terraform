provider "null" {}

provider "google" {
  project     = var.project_id
  region      = var.project_region
  credentials = file("terraform-sa.json")
}
terraform {
  backend "gcs" {
    bucket = "scales-state-dev"
    prefix = "terraform/state/dialogflow-cx"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.26.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

