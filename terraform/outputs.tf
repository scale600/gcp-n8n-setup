output "instance_ip" {
  description = "The external IP address of the n8n compute instance."
  value       = google_compute_address.static_ip.address
}