# Terraform configuration for n8n on GCP free tier
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.51"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Reserve a static IP address (free tier eligible)
resource "google_compute_address" "n8n_static_ip" {
  name = var.static_ip_name
}

# Create a GCP Compute Engine instance (e2-micro is free tier)
resource "google_compute_instance" "n8n_server" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.gcp_zone

  tags = ["n8n-server"]

  boot_disk {
    initialize_params {
      image = var.image_family
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.n8n_static_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Firewall rule for n8n
resource "google_compute_firewall" "n8n_firewall" {
  name    = var.firewall_name
  network = "default"

  allow {
    protocol = "tcp"
    ports    = [var.firewall_port]
  }

  target_tags   = ["n8n-server"]
  source_ranges = ["0.0.0.0/0"]
}

# Output the instance IP
output "n8n_ip" {
  description = "The external IP address of the n8n server"
  value       = google_compute_address.n8n_static_ip.address
}
