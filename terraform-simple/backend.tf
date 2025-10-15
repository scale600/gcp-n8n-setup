# Terraform backend configuration for state management
# This stores the Terraform state in Google Cloud Storage
# to enable state sharing across deployments and team members

terraform {
  backend "gcs" {
    # The GCS bucket name for storing Terraform state
    # This should be unique across your organization
    bucket = "terraform-state-n8n-deployment"
    
    # The path within the bucket to store the state file
    prefix = "n8n-deployment/state"
    
    # Optional: Enable state encryption
    # encryption_key = "your-encryption-key"
  }
}
