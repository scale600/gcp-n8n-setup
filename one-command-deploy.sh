#!/bin/bash

# One-Command n8n Deployment
# 단일 명령어로 GCP에 n8n을 배포합니다

set -e

# Check if GCP_PROJECT_ID is set
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "❌ GCP_PROJECT_ID environment variable is required"
    echo "Usage: export GCP_PROJECT_ID=your-project-id && $0"
    exit 1
fi

echo "🚀 Deploying n8n to GCP project: $GCP_PROJECT_ID"

# Create firewall rule
echo "📡 Creating firewall rule..."
gcloud compute firewall-rules create allow-n8n \
    --allow tcp:5678 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow n8n access" \
    --project="$GCP_PROJECT_ID" 2>/dev/null || echo "Firewall rule already exists"

# Create and start instance
echo "🖥️  Creating GCP instance..."
gcloud compute instances create n8n-simple \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --tags=n8n-server \
    --metadata=startup-script='#!/bin/bash
apt-get update
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
mkdir -p /home/admin/n8n
cd /home/admin/n8n
cat > docker-compose.yml << EOF
version: "3"
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
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF
docker-compose up -d' \
    --project="$GCP_PROJECT_ID"

# Get IP address
echo "🔍 Getting instance IP..."
sleep 10
INSTANCE_IP=$(gcloud compute instances describe n8n-simple \
    --zone=us-central1-a \
    --project="$GCP_PROJECT_ID" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "✅ n8n deployment completed!"
echo "🌐 Access n8n at: http://$INSTANCE_IP:5678"
echo "⏰ Please wait 2-3 minutes for n8n to start up"
echo ""
echo "📝 To clean up later, run:"
echo "   gcloud compute instances delete n8n-simple --zone=us-central1-a --project=$GCP_PROJECT_ID"
echo "   gcloud compute firewall-rules delete allow-n8n --project=$GCP_PROJECT_ID"
