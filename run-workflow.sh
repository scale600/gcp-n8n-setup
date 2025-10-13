#!/bin/bash

# n8n Workflow Runner
# This script provides an easy way to run the n8n deployment workflow

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "This is not a git repository. Please run this script from the project root."
        exit 1
    fi
}

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first:"
        echo "  brew install gh  # macOS"
        echo "  apt install gh   # Ubuntu/Debian"
        exit 1
    fi
}

# Trigger GitHub Actions workflow
trigger_github_workflow() {
    print_status "Triggering GitHub Actions workflow..."
    
    # Check if we're authenticated with GitHub
    if ! gh auth status > /dev/null 2>&1; then
        print_error "Not authenticated with GitHub. Please run: gh auth login"
        exit 1
    fi
    
    # Get the repository name
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    
    # Trigger the workflow
    gh workflow run deploy.yml
    
    print_success "GitHub Actions workflow triggered successfully!"
    print_status "You can monitor the progress at: https://github.com/$REPO/actions"
}

# Run local deployment
run_local_deployment() {
    print_status "Running local deployment..."
    
    # Check if required environment variables are set
    if [ -z "$GCP_PROJECT_ID" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$SSH_PUBLIC_KEY" ]; then
        print_error "Required environment variables are not set."
        echo ""
        echo "Please set the following environment variables:"
        echo "  export GCP_PROJECT_ID=your-project-id"
        echo "  export DOMAIN_NAME=your-domain.com"
        echo "  export SSH_PUBLIC_KEY=\"\$(cat ~/.ssh/id_rsa.pub)\""
        echo ""
        echo "Then run: $0 --local"
        exit 1
    fi
    
    # Run the deployment script
    ./deploy.sh
}

# Show help
show_help() {
    echo "n8n Workflow Runner"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --github     Trigger GitHub Actions workflow (default)"
    echo "  --local      Run local deployment with Terraform and Ansible"
    echo "  --check      Check dependencies and environment"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Trigger GitHub Actions workflow"
    echo "  $0 --github          # Same as above"
    echo "  $0 --local           # Run local deployment"
    echo "  $0 --check           # Check setup"
    echo ""
    echo "For local deployment, make sure to set these environment variables:"
    echo "  GCP_PROJECT_ID    Your GCP project ID"
    echo "  DOMAIN_NAME       Your domain name (e.g., n8n.example.com)"
    echo "  SSH_PUBLIC_KEY    Your SSH public key"
}

# Main function
main() {
    case "${1:-github}" in
        --github|github|"")
            check_git_repo
            check_gh_cli
            trigger_github_workflow
            ;;
        --local|local)
            run_local_deployment
            ;;
        --check|check)
            ./deploy.sh --check-only
            ;;
        -h|--help)
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
