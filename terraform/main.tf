# Terraform configuration for GCP provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
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

  tags = ["http-server", "https-server", "ssh"]

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

# Firewall rule for HTTP traffic
resource "google_compute_firewall" "http" {
  name    = "allow-http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags   = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
}

# Firewall rule for HTTPS traffic
resource "google_compute_firewall" "https" {
  name    = "allow-https"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags   = ["https-server"]
  source_ranges = ["0.0.0.0/0"]
}

# Firewall rule for SSH traffic
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["ssh"]
  source_ranges = ["0.0.0.0/0"] # For simplicity, allows SSH from anywhere. For production, restrict this to a specific IP range.
}