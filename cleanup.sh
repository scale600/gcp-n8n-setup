#!/bin/bash

# Cleanup script for n8n GCP deployment
# This script destroys all resources created by Terraform

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

# Load environment variables from .env file
if [ -f .env ]; then
    print_status "Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
    print_success "Environment variables loaded"
else
    print_warning ".env file not found. Please create one from .env.example"
    print_status "Using default values or environment variables"
fi

# Check if required environment variables are set
check_environment() {
    print_status "Checking environment variables..."
    
    if [ -z "$GCP_PROJECT_ID" ]; then
        print_error "GCP_PROJECT_ID environment variable is not set."
        print_status "Please set it with: export GCP_PROJECT_ID=your-project-id"
        exit 1
    fi
    
    if [ -z "$SSH_PUBLIC_KEY" ]; then
        print_warning "SSH_PUBLIC_KEY not set, trying to use default key..."
        if [ -f ~/.ssh/id_rsa.pub ]; then
            export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
            print_success "Using SSH key from ~/.ssh/id_rsa.pub"
        else
            print_error "SSH public key not found. Please set SSH_PUBLIC_KEY or create ~/.ssh/id_rsa.pub"
            exit 1
        fi
    fi
    
    print_success "Environment variables are set."
}

# Destroy infrastructure with Terraform
destroy_infrastructure() {
    print_status "🧹 Destroying infrastructure with Terraform..."
    
    cd terraform
    
    # Check if terraform state exists
    if [ ! -f terraform.tfstate ]; then
        print_warning "No Terraform state found. Nothing to destroy."
        cd ..
        return
    fi
    
    # Show what will be destroyed
    print_status "Planning destruction..."
    terraform plan -destroy -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"
    
    # Confirm destruction
    echo ""
    print_warning "This will destroy all GCP resources created by this deployment."
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_status "Destruction cancelled."
        cd ..
        exit 0
    fi
    
    # Destroy resources
    print_status "Destroying resources..."
    terraform destroy -auto-approve -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"
    
    print_success "Infrastructure destroyed successfully!"
    
    cd ..
}

# Clean up local files
cleanup_local() {
    print_status "Cleaning up local files..."
    
    # Remove Ansible inventory
    if [ -f ansible/inventory.ini ]; then
        rm ansible/inventory.ini
        print_status "Removed Ansible inventory file"
    fi
    
    # Remove Terraform state files (optional)
    if [ -d terraform/.terraform ]; then
        rm -rf terraform/.terraform
        print_status "Removed Terraform cache"
    fi
    
    print_success "Local cleanup completed!"
}

# Main cleanup function
main() {
    print_status "🧹 Starting cleanup process..."
    echo ""
    
    check_environment
    destroy_infrastructure
    cleanup_local
    
    print_success "🎉 Cleanup completed successfully!"
    echo ""
    print_status "All GCP resources have been destroyed."
    print_status "Local files have been cleaned up."
    echo ""
    print_warning "Note: This action cannot be undone."
}

# Help function
show_help() {
    echo "n8n GCP Cleanup Script"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Required Environment Variables:"
    echo "  GCP_PROJECT_ID    Your GCP project ID"
    echo "  SSH_PUBLIC_KEY    (Optional) Your SSH public key (defaults to ~/.ssh/id_rsa.pub)"
    echo ""
    echo "Example:"
    echo "  export GCP_PROJECT_ID=my-project"
    echo "  ./cleanup.sh"
    echo ""
    echo "This script will:"
    echo "  1. Destroy all GCP resources (VM, IP, firewall)"
    echo "  2. Clean up local files"
    echo "  3. Confirm completion"
    echo ""
    echo "WARNING: This action cannot be undone!"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
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
