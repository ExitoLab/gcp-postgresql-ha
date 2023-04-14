# Define the variables
variable "project_id" {
  type        = string
  description = ""
}

variable "region" {
  type        = string
  description = ""
}

variable "zone" {
  type        = string
  description = ""
}

variable "privatekeypath" {
    type = string
    default = "id_rsa"
}

variable "publickeypath" {
    type = string
    default = "id_rsa.pub"
}

variable "user" {
    type = string
    default = "ubuntu"
}

variable "image" {
    type = string
    default = "ubuntu-os-cloud/ubuntu-1804-lts"
}