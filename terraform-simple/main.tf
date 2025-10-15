# Simple Terraform configuration for n8n
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
  
  # Backend configuration is in backend.tf
  # This enables remote state storage in Google Cloud Storage
}

# Configure the Google Cloud provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Reserve a static IP address
resource "google_compute_address" "static_ip" {
  name = "n8n-static-ip"
}

# Create a GCP Compute Engine instance
resource "google_compute_instance" "n8n_instance" {
  name         = "n8n-server"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-a"

  tags = ["n8n-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Simple firewall rule for n8n (port 5678)
resource "google_compute_firewall" "n8n" {
  name    = "allow-n8n"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["5678"]
  }
  target_tags   = ["n8n-server"]
  source_ranges = ["0.0.0.0/0"]
}

# Output the instance IP
output "instance_ip" {
  description = "The external IP address of the n8n compute instance."
  value       = google_compute_address.static_ip.address
}
