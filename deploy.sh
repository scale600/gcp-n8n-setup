#!/bin/bash

# n8n GCP Free Tier Deployment Script
# This script automates the entire deployment process

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

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK (gcloud) is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible is not installed. Please install Ansible first."
        exit 1
    fi
    
    print_success "All dependencies are installed."
}

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

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "🚀 Step 1: Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    print_status "Planning Terraform deployment..."
    terraform plan \
        -var="gcp_project_id=$GCP_PROJECT_ID" \
        -var="gcp_region=$GCP_REGION" \
        -var="gcp_zone=$GCP_ZONE" \
        -var="instance_name=$INSTANCE_NAME" \
        -var="machine_type=$MACHINE_TYPE" \
        -var="disk_size=$DISK_SIZE" \
        -var="image_family=$IMAGE_FAMILY" \
        -var="static_ip_name=$STATIC_IP_NAME" \
        -var="firewall_name=$FIREWALL_NAME" \
        -var="firewall_port=$FIREWALL_PORT" \
        -var="ssh_user=$SSH_USER" \
        -var="ssh_public_key=$SSH_PUBLIC_KEY"
    
    # Apply deployment
    print_status "Applying Terraform deployment..."
    terraform apply -auto-approve \
        -var="gcp_project_id=$GCP_PROJECT_ID" \
        -var="gcp_region=$GCP_REGION" \
        -var="gcp_zone=$GCP_ZONE" \
        -var="instance_name=$INSTANCE_NAME" \
        -var="machine_type=$MACHINE_TYPE" \
        -var="disk_size=$DISK_SIZE" \
        -var="image_family=$IMAGE_FAMILY" \
        -var="static_ip_name=$STATIC_IP_NAME" \
        -var="firewall_name=$FIREWALL_NAME" \
        -var="firewall_port=$FIREWALL_PORT" \
        -var="ssh_user=$SSH_USER" \
        -var="ssh_public_key=$SSH_PUBLIC_KEY"
    
    # Get the server IP
    SERVER_IP=$(terraform output -raw n8n_ip)
    print_success "Infrastructure deployed! Server IP: $SERVER_IP"
    
    cd ..
}

# Configure server with Ansible
configure_server() {
    print_status "🔧 Step 2: Configuring server with Ansible..."
    
    cd ansible
    
    # Install Ansible requirements
    print_status "Installing Ansible requirements..."
    ansible-galaxy install -r requirements.yml
    
    # Create inventory file
    print_status "Creating Ansible inventory..."
    cat > inventory.ini << EOF
[n8n_server]
$SERVER_IP ansible_user=$ANSIBLE_USER ansible_ssh_private_key_file=$ANSIBLE_SSH_PRIVATE_KEY_FILE
EOF
    
    # Wait for SSH to be available
    print_status "Waiting for SSH to be available..."
    sleep 30
    
    # Run Ansible playbook
    print_status "Running Ansible playbook..."
    ansible-playbook -i inventory.ini playbook.yml \
        -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" \
        -e "n8n_port=$N8N_PORT" \
        -e "n8n_host=$N8N_HOST" \
        -e "n8n_protocol=$N8N_PROTOCOL" \
        -e "n8n_timezone=$N8N_TIMEZONE" \
        -e "n8n_basic_auth_user=$N8N_BASIC_AUTH_USER" \
        -e "n8n_basic_auth_password=$N8N_BASIC_AUTH_PASSWORD" \
        -e "n8n_secure_cookie=$N8N_SECURE_COOKIE"
    
    print_success "Server configuration completed!"
    
    cd ..
}

# Display final information
show_completion() {
    print_success "🎉 Deployment completed successfully!"
    echo ""
    print_status "n8n is now running on your GCP free tier instance!"
    echo ""
    echo -e "${GREEN}Access Information:${NC}"
    echo -e "  URL: ${BLUE}http://$SERVER_IP:5678${NC}"
    echo -e "  Username: ${YELLOW}admin${NC}"
    echo -e "  Password: ${YELLOW}admin123${NC}"
    echo ""
    echo -e "${GREEN}Server Details:${NC}"
    echo -e "  IP Address: ${BLUE}$SERVER_IP${NC}"
    echo -e "  Instance: ${BLUE}e2-micro (free tier)${NC}"
    echo -e "  OS: ${BLUE}Debian 11${NC}"
    echo -e "  Swap: ${BLUE}1GB${NC}"
    echo ""
    echo -e "${GREEN}Next Steps:${NC}"
    echo -e "  1. Open ${BLUE}http://$SERVER_IP:5678${NC} in your browser"
    echo -e "  2. Login with admin/admin123"
    echo -e "  3. Change the default password"
    echo -e "  4. Start creating your workflows!"
    echo ""
    print_warning "Remember: This is running on GCP free tier with limited resources."
    print_warning "For production use, consider upgrading to a larger instance."
}

# Main deployment function
main() {
    print_status "🎯 Starting n8n deployment on GCP free tier..."
    echo ""
    
    check_dependencies
    check_environment
    deploy_infrastructure
    configure_server
    show_completion
}

# Help function
show_help() {
    echo "n8n GCP Free Tier Deployment Script"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Required Environment Variables:"
    echo "  GCP_PROJECT_ID    Your GCP project ID"
    echo "  SSH_PUBLIC_KEY    (Optional) Your SSH public key (defaults to ~/.ssh/id_rsa.pub)"
    echo ""
    echo "Example:"
    echo "  export GCP_PROJECT_ID=my-project"
    echo "  ./deploy.sh"
    echo ""
    echo "This script will:"
    echo "  1. Deploy GCP infrastructure (e2-micro, static IP, firewall)"
    echo "  2. Configure server (1GB swap, Docker, n8n)"
    echo "  3. Start n8n container"
    echo "  4. Display access information"
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
