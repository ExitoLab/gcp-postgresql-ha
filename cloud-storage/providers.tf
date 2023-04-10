provider "google" {
  credentials = file("credentials.json")

  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}
