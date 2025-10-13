variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "us-central1"
}

variable "ssh_user" {
  description = "The username for SSH access."
  type        = string
  default     = "admin"
}

variable "ssh_public_key" {
  description = "The public SSH key for accessing the instance."
  type        = string
  sensitive   = true
}