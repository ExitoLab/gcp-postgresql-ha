variable "gcp_services_list" {
  description = "The list of GCP APIs necessary for the project."
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

/* ## terraform.tfvars
gcp_env_services_list = [
  "cloudresourcemanager.googleapis.com",
  "servicenetworking.googleapis.com"
] */

/* ## main.tf
resource "google_project" "project" {
  name       = "api-k8-demo"
  project_id = "fleet-pillar-238009"
} */

resource "google_project_service" "enable_google_apis" {
  count = length(var.gcp_services_list)

  project = "fleet-pillar-238009"
  service = var.gcp_services_list[count.index]

  disable_dependent_services = true
}