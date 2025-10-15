#!/bin/bash

# Setup Terraform Backend Script
# This script creates a Google Cloud Storage bucket for Terraform state management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK is not installed. Please install gcloud first."
        exit 1
    fi
    
    print_success "All dependencies are installed."
}

# Check if required environment variables are set
check_environment() {
    print_status "Checking environment variables..."
    
    if [ -z "$GCP_PROJECT_ID" ]; then
        print_error "GCP_PROJECT_ID environment variable is not set."
        exit 1
    fi
    
    if [ -z "$GCP_REGION" ]; then
        export GCP_REGION="us-central1"
        print_warning "GCP_REGION not set, using default: $GCP_REGION"
    fi
    
    print_success "Environment variables are set."
}

# Create GCS bucket for Terraform state
create_state_bucket() {
    print_status "Creating GCS bucket for Terraform state..."
    
    BUCKET_NAME="terraform-state-n8n-deployment"
    
    # Check if bucket already exists
    if gsutil ls -b gs://$BUCKET_NAME >/dev/null 2>&1; then
        print_warning "Bucket gs://$BUCKET_NAME already exists."
    else
        # Create the bucket
        print_status "Creating bucket: gs://$BUCKET_NAME"
        gsutil mb -p $GCP_PROJECT_ID -c STANDARD -l $GCP_REGION gs://$BUCKET_NAME
        
        # Enable versioning for state file safety
        print_status "Enabling versioning on bucket..."
        gsutil versioning set on gs://$BUCKET_NAME
        
        print_success "Bucket created successfully!"
    fi
    
    # Set bucket permissions (optional - for team access)
    print_status "Setting bucket permissions..."
    gsutil iam ch serviceAccount:$GCP_PROJECT_ID@appspot.gserviceaccount.com:objectAdmin gs://$BUCKET_NAME || print_warning "Could not set service account permissions"
    
    print_success "Terraform state bucket setup completed!"
    print_status "Bucket: gs://$BUCKET_NAME"
    print_status "Region: $GCP_REGION"
}

# Initialize Terraform with backend
init_terraform() {
    print_status "Initializing Terraform with backend..."
    
    cd terraform-simple
    
    # Initialize Terraform
    terraform init
    
    print_success "Terraform initialized with backend!"
    
    cd ..
}

# Main setup function
main() {
    print_status "Setting up Terraform backend for n8n deployment..."
    
    check_dependencies
    check_environment
    create_state_bucket
    init_terraform
    
    print_success "🎉 Terraform backend setup completed!"
    print_status "Your Terraform state will now be stored in Google Cloud Storage"
    print_status "This enables state sharing across deployments and team members"
    print_warning "Make sure to run this script before your first deployment"
}

# Help function
show_help() {
    echo "Terraform Backend Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --check-only   Only check dependencies and environment"
    echo ""
    echo "Required Environment Variables:"
    echo "  GCP_PROJECT_ID    Your GCP project ID"
    echo "  GCP_REGION        GCP region (optional, defaults to us-central1)"
    echo ""
    echo "Example:"
    echo "  export GCP_PROJECT_ID=my-project"
    echo "  export GCP_REGION=us-central1"
    echo "  $0"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --check-only)
        check_dependencies
        check_environment
        print_success "All checks passed!"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
