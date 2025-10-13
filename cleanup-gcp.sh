#!/bin/bash

# GCP n8n 리소스 정리 스크립트
# 이 스크립트는 기존에 생성된 n8n 관련 GCP 리소스들을 삭제합니다

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

# Check if GCP_PROJECT_ID is set
if [ -z "$GCP_PROJECT_ID" ]; then
    print_error "GCP_PROJECT_ID environment variable is not set."
    echo "Please set it with: export GCP_PROJECT_ID=your-project-id"
    exit 1
fi

print_status "Starting cleanup of GCP resources for project: $GCP_PROJECT_ID"

# Delete Compute Engine instance
print_status "Deleting Compute Engine instance..."
gcloud compute instances delete n8n-server --zone=us-central1-a --project=$GCP_PROJECT_ID --quiet || print_warning "Instance n8n-server not found or already deleted"

# Delete static IP address
print_status "Deleting static IP address..."
gcloud compute addresses delete n8n-static-ip --region=us-central1 --project=$GCP_PROJECT_ID --quiet || print_warning "Static IP n8n-static-ip not found or already deleted"

# Delete firewall rules
print_status "Deleting firewall rules..."
gcloud compute firewall-rules delete allow-http --project=$GCP_PROJECT_ID --quiet || print_warning "Firewall rule allow-http not found or already deleted"
gcloud compute firewall-rules delete allow-https --project=$GCP_PROJECT_ID --quiet || print_warning "Firewall rule allow-https not found or already deleted"
gcloud compute firewall-rules delete allow-ssh --project=$GCP_PROJECT_ID --quiet || print_warning "Firewall rule allow-ssh not found or already deleted"

print_success "GCP resources cleanup completed!"
print_status "You can now run the deployment workflow again."
