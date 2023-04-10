# //////////////////////////////
# VARIABLES
# //////////////////////////////

variable "project_id" {
  type        = string
  default     = "fleet-pillar-238009"
  description = "The project id"
}

variable "region" {
  type        = string
  description = "region"
  default     = "us-central1"
}
