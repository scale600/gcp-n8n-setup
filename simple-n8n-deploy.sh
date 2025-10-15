#!/bin/bash

# Simple n8n Deployment Script for GCP
# 최소한의 구성으로 n8n을 GCP에 배포합니다

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
    
    if [ -z "$GCP_ZONE" ]; then
        export GCP_ZONE="us-central1-a"
        print_warning "GCP_ZONE not set, using default: $GCP_ZONE"
    fi
    
    print_success "Environment variables are set."
}

# Create GCP instance with n8n
create_n8n_instance() {
    print_status "Creating GCP instance with n8n..."
    
    # Create firewall rule for n8n (port 5678)
    print_status "Creating firewall rule for n8n..."
    gcloud compute firewall-rules create allow-n8n \
        --allow tcp:5678 \
        --source-ranges 0.0.0.0/0 \
        --description "Allow n8n access" \
        --project="$GCP_PROJECT_ID" || print_warning "Firewall rule may already exist"
    
    # Create startup script for n8n
    cat > startup-script.sh << 'EOF'
#!/bin/bash
# Update system
apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add user to docker group
usermod -aG docker admin

# Create n8n directory
mkdir -p /home/admin/n8n
cd /home/admin/n8n

# Create docker-compose.yml
cat > docker-compose.yml << 'DOCKER_EOF'
version: '3'

services:
  n8n:
    image: n8nio/n8n
    container_name: n8n
    restart: always
    ports:
      - "0.0.0.0:5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - GENERIC_TIMEZONE=Asia/Seoul
    volumes:
      - ./n8n_data:/home/node/.n8n
DOCKER_EOF

# Start n8n
docker-compose up -d

# Wait for n8n to start
sleep 30

# Get external IP
EXTERNAL_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
echo "n8n is available at: http://$EXTERNAL_IP:5678"
EOF

    # Create the instance
    print_status "Creating GCP instance..."
    gcloud compute instances create n8n-simple \
        --zone="$GCP_ZONE" \
        --machine-type=e2-micro \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --boot-disk-size=10GB \
        --boot-disk-type=pd-standard \
        --tags=n8n-server \
        --metadata-from-file startup-script=startup-script.sh \
        --project="$GCP_PROJECT_ID"
    
    # Clean up startup script
    rm -f startup-script.sh
    
    print_success "GCP instance created successfully!"
}

# Get instance IP
get_instance_ip() {
    print_status "Getting instance IP..."
    
    INSTANCE_IP=$(gcloud compute instances describe n8n-simple \
        --zone="$GCP_ZONE" \
        --project="$GCP_PROJECT_ID" \
        --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
    
    if [ -z "$INSTANCE_IP" ]; then
        print_error "Failed to get instance IP"
        exit 1
    fi
    
    print_success "Instance IP: $INSTANCE_IP"
    echo "🌐 n8n will be available at: http://$INSTANCE_IP:5678"
    echo "⏰ Please wait 2-3 minutes for n8n to start up completely"
}

# Main deployment function
main() {
    print_status "Starting simple n8n deployment to GCP..."
    
    check_dependencies
    check_environment
    create_n8n_instance
    get_instance_ip
    
    print_success "🎉 Simple n8n deployment completed!"
    print_warning "Note: This is a basic setup without SSL or domain configuration."
    print_warning "For production use, consider adding SSL and proper security measures."
}

# Help function
show_help() {
    echo "Simple n8n Deployment Script"
    echo ""
    echo "Usage: $0"
    echo ""
    echo "Required Environment Variables:"
    echo "  GCP_PROJECT_ID    Your GCP project ID"
    echo "  GCP_ZONE         GCP zone (optional, defaults to us-central1-a)"
    echo ""
    echo "Example:"
    echo "  export GCP_PROJECT_ID=my-project"
    echo "  export GCP_ZONE=us-central1-a"
    echo "  $0"
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
