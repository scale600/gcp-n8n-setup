variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "The GCP zone to deploy resources in"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "The name of the compute instance"
  type        = string
  default     = "n8n-server"
}

variable "machine_type" {
  description = "The machine type for the compute instance"
  type        = string
  default     = "e2-micro"
}

variable "disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 30
}

variable "image_family" {
  description = "The image family for the boot disk"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "static_ip_name" {
  description = "The name of the static IP address"
  type        = string
  default     = "n8n-static-ip"
}

variable "firewall_name" {
  description = "The name of the firewall rule"
  type        = string
  default     = "allow-n8n"
}

variable "firewall_port" {
  description = "The port to allow in the firewall rule"
  type        = string
  default     = "5678"
}

variable "ssh_user" {
  description = "The username for SSH access to the instance"
  type        = string
  default     = "admin"
}

variable "ssh_public_key" {
  description = "The public SSH key for accessing the instance"
  type        = string
  sensitive   = true
}