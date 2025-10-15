#!/bin/bash

# Simple Terraform + Ansible + Docker n8n Deployment
# Terraform → Create GCP Infrastructure
# Ansible → Configure Server and Install n8n
# Docker → Run n8n Container
# Complete! (Access via IP:5678)

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
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
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
    
    if [ -z "$SSH_PUBLIC_KEY" ]; then
        print_error "SSH_PUBLIC_KEY environment variable is not set."
        exit 1
    fi
    
    print_success "Environment variables are set."
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "🚀 Step 1: Deploying infrastructure with Terraform..."
    
    cd terraform-simple
    
    # Check if backend bucket exists
    print_status "Checking Terraform backend configuration..."
    if ! gsutil ls -b gs://terraform-state-n8n-deployment >/dev/null 2>&1; then
        print_warning "Terraform state bucket not found. Please run setup-terraform-backend.sh first."
        print_status "Or run: ./setup-terraform-backend.sh"
        exit 1
    fi
    
    # Initialize Terraform with backend
    print_status "Initializing Terraform with backend..."
    terraform init
    
    # Plan the deployment
    print_status "Planning Terraform deployment..."
    terraform plan -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"
    
    # Apply the deployment
    print_status "Applying Terraform deployment..."
    terraform apply -auto-approve -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"
    
    # Get the instance IP
    INSTANCE_IP=$(terraform output -raw instance_ip)
    
    if [ -z "$INSTANCE_IP" ]; then
        print_error "Failed to retrieve instance IP."
        exit 1
    fi
    
    print_success "Infrastructure deployed successfully. Instance IP: $INSTANCE_IP"
    
    cd ..
}

# Configure server with Ansible
configure_server() {
    print_status "⚙️  Step 2: Configuring server with Ansible..."
    
    cd ansible-simple
    
    # Create inventory file
    print_status "Creating Ansible inventory..."
    cat > inventory.ini << EOF
[n8n_server]
$INSTANCE_IP ansible_user=admin ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
    
    # Install Ansible collections
    print_status "Installing Ansible collections..."
    ansible-galaxy install -r requirements.yml
    
    # Wait for SSH to be available
    print_status "Waiting for SSH to be available..."
    sleep 30
    
    # Run Ansible playbook
    print_status "Running Ansible playbook..."
    ansible-playbook -i inventory.ini playbook.yml -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
    
    # Cleanup
    rm -f inventory.ini
    
    print_success "Server configuration completed."
    
    cd ..
}

# Main deployment function
main() {
    print_status "🎯 Starting simple n8n deployment (Terraform + Ansible + Docker)..."
    
    check_dependencies
    check_environment
    deploy_infrastructure
    configure_server
    
    print_success "🎉 Deployment completed successfully!"
    print_status "🌐 Your n8n instance is available at: http://$INSTANCE_IP:5678"
    print_warning "⏰ Please wait 1-2 minutes for n8n to fully start up"
    print_warning "📝 To clean up: cd terraform-simple && terraform destroy"
}

# Help function
show_help() {
    echo "Simple n8n Deployment Script (Terraform + Ansible + Docker)"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --check-only   Only check dependencies and environment"
    echo ""
    echo "Required Environment Variables:"
    echo "  GCP_PROJECT_ID    Your GCP project ID"
    echo "  SSH_PUBLIC_KEY    Your SSH public key"
    echo ""
    echo "Example:"
    echo "  export GCP_PROJECT_ID=my-project"
    echo "  export SSH_PUBLIC_KEY=\"\$(cat ~/.ssh/id_rsa.pub)\""
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
