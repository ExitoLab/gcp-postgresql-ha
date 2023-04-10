terraform {
  backend "gcs" {
    bucket = "94385c9eb8ae75a5-bucket-tfstate"
    prefix = "sql/terraform.state"
  }
  required_version = ">= 0.14"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}