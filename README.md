# n8n on GCP Free Tier

A simple, cost-effective setup for running n8n workflow automation on Google Cloud Platform using the free tier.

## 🎯 **What This Does**

1. **Terraform** → Creates GCP infrastructure (free tier eligible)
2. **Ansible** → Configures server with 1GB swap + Docker + n8n
3. **Docker** → Runs n8n container with secure cookie disabled
4. **Result** → Access n8n at `http://[IP]:5678` (admin/admin123)

## 📋 **Prerequisites**

- Google Cloud Platform account with billing enabled
- `gcloud` CLI installed and authenticated
- `terraform` installed
- `ansible` installed
- SSH key pair generated (`~/.ssh/id_rsa`)

## 🏗️ **Architecture**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│  GCP Free Tier   │───▶│   Ansible       │
│                 │    │                  │    │                 │
│ • e2-micro VM   │    │ • Static IP      │    │ • 1GB Swap      │
│ • Firewall      │    │ • Debian 11      │    │ • Docker        │
│ • Static IP     │    │ • Port 5678      │    │ • n8n Container │
│ • 30GB Disk     │    │ • 30GB Storage   │    │ • Secure Cookie │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 **Quick Start**

### **One-Command Deployment**

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env file with your settings
nano .env

# 3. Deploy everything
./deploy.sh
```

### **Environment Configuration**

#### **.env File Setup**

The project uses a `.env` file to manage all configuration variables. This makes it easy to customize settings without modifying code.

```bash
# Copy the example file
cp .env.example .env

# Edit with your settings
nano .env
```

**Key variables to configure:**

- `GCP_PROJECT_ID`: Your GCP project ID
- `SSH_PUBLIC_KEY_FILE`: Path to your SSH public key
- `N8N_BASIC_AUTH_PASSWORD`: Change default password
- `N8N_TIMEZONE`: Set your timezone

### **Manual Step-by-Step**

#### 1. **Setup Environment**

```bash
# Load environment variables
source .env

# Or set manually
export GCP_PROJECT_ID="your-project-id"
export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
```

#### 2. **Deploy Infrastructure**

```bash
# Deploy with Terraform
cd terraform
terraform init
terraform plan -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"
terraform apply -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"

# Get the server IP
terraform output n8n_ip
```

#### 3. **Configure Server**

```bash
# Install Ansible requirements
ansible-galaxy collection install -r ansible/requirements.yml

# Create Ansible inventory
echo "[n8n_server]" > ansible/inventory.ini
echo "$(terraform output -raw n8n_ip) ansible_user=admin ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ansible/inventory.ini

# Run Ansible playbook
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -e "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
```

#### 4. **Access n8n**

Open your browser and go to: `http://[SERVER_IP]:5678`

**Default Credentials:**

- Username: `admin`
- Password: `admin123`

## 📁 **Project Structure**

```
├── README.md              # Complete documentation
├── .env.example           # Environment variables template
├── .env                   # Your environment variables (create from .env.example)
├── deploy.sh              # One-command deployment
├── cleanup.sh             # Easy cleanup script
├── .gitignore             # Git ignore file
├── terraform/
│   ├── main.tf           # GCP infrastructure (free tier)
│   └── variables.tf      # Input variables
└── ansible/
    ├── playbook.yml      # Server setup + 1GB swap + Docker + n8n
    └── requirements.yml  # Ansible dependencies
```

## 💰 **Cost Breakdown (Free Tier)**

- **Compute Engine**: e2-micro (1 vCPU, 1GB RAM) - **FREE**
- **Static IP**: External IP address - **FREE** (when attached to running instance)
- **Storage**: 30GB persistent disk - **FREE** (up to 30GB)
- **Network**: Firewall rules and egress - **FREE**

**Total Monthly Cost: $0.00** 🎉

## 🔧 **Configuration Details**

### **Environment Variables (.env)**

The project uses environment variables for all configuration. Key variables include:

**GCP Settings:**

- `GCP_PROJECT_ID`: Your GCP project ID
- `GCP_REGION`: GCP region (default: us-central1)
- `GCP_ZONE`: GCP zone (default: us-central1-a)

**Instance Settings:**

- `INSTANCE_NAME`: VM instance name (default: n8n-server)
- `MACHINE_TYPE`: VM type (default: e2-micro)
- `DISK_SIZE`: Boot disk size in GB (default: 30)

**n8n Settings:**

- `N8N_PORT`: n8n port (default: 5678)
- `N8N_BASIC_AUTH_USER`: Login username (default: admin)
- `N8N_BASIC_AUTH_PASSWORD`: Login password (default: admin123)
- `N8N_TIMEZONE`: Timezone (default: Asia/Seoul)
- `N8N_SECURE_COOKIE`: Secure cookie setting (default: false)

### **Terraform Resources**

- **Instance**: e2-micro (free tier eligible)
- **OS**: Debian 11 (debian-cloud/debian-11)
- **Disk**: 30GB persistent disk (free tier maximum)
- **Network**: Default VPC with external IP
- **Firewall**: Port 5678 open to all IPs

### **Ansible Configuration**

- **Swap**: 1GB swap file for better performance
- **Docker**: Latest Docker Engine installation
- **n8n**: Latest n8n container with persistent data
- **Timezone**: Asia/Seoul (configurable)
- **Security**: N8N_SECURE_COOKIE=false for HTTP access

### **n8n Configuration**

```yaml
environment:
  - N8N_HOST=0.0.0.0
  - N8N_PORT=5678
  - N8N_PROTOCOL=http
  - NODE_ENV=production
  - GENERIC_TIMEZONE=Asia/Seoul
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=admin123
  - N8N_SECURE_COOKIE=false
```

## 🛠️ **Deployment Scripts**

### **deploy.sh** - Complete Deployment

```bash
#!/bin/bash
# Automates the entire deployment process:
# 1. Checks dependencies
# 2. Deploys infrastructure with Terraform
# 3. Configures server with Ansible
# 4. Provides access information
```

### **cleanup.sh** - Resource Cleanup

```bash
#!/bin/bash
# Destroys all GCP resources created by Terraform
```

## 🔍 **Troubleshooting**

### **Common Issues**

1. **SSH Connection Failed**

   ```bash
   # Wait for instance to be ready
   sleep 60

   # Test SSH connection
   ssh -o StrictHostKeyChecking=no admin@[SERVER_IP]
   ```

2. **n8n Not Accessible**

   ```bash
   # Check if container is running
   ssh -o StrictHostKeyChecking=no admin@[SERVER_IP] "sudo docker ps"

   # Check n8n logs
   ssh -o StrictHostKeyChecking=no admin@[SERVER_IP] "sudo docker logs n8n"
   ```

3. **Docker Permission Issues**

   ```bash
   # Fix Docker permissions
   ssh -o StrictHostKeyChecking=no admin@[SERVER_IP] "sudo usermod -aG docker admin"
   ```

4. **Secure Cookie Warning**

   The setup includes `N8N_SECURE_COOKIE=false` to allow HTTP access. For production, consider setting up HTTPS.

### **Manual Container Management**

```bash
# Start n8n container
ssh -o StrictHostKeyChecking=no admin@[SERVER_IP] "sudo docker compose -f /home/admin/n8n/docker-compose.yml up -d"

# Stop n8n container
ssh -o StrictHostKeyChecking=no admin@[SERVER_IP] "sudo docker compose -f /home/admin/n8n/docker-compose.yml down"

# Restart n8n container
ssh -o StrictHostKeyChecking=no admin@[SERVER_IP] "sudo docker compose -f /home/admin/n8n/docker-compose.yml restart"
```

## 🧹 **Cleanup**

### **Using Cleanup Script**

```bash
./cleanup.sh
```

### **Manual Cleanup**

```bash
cd terraform
terraform destroy -var="gcp_project_id=$GCP_PROJECT_ID" -var="ssh_public_key=$SSH_PUBLIC_KEY"
```

## 🔒 **Security Notes**

- **Basic Auth**: Enabled with default credentials (admin/admin123)
- **Secure Cookies**: Disabled for HTTP access
- **Firewall**: Port 5678 open to all IPs (0.0.0.0/0)
- **SSH**: Key-based authentication only

**For Production Use:**

- Change default credentials
- Set up HTTPS/TLS
- Restrict firewall rules
- Enable secure cookies
- Set up proper backup strategy

## 📝 **Notes**

- This setup uses GCP free tier resources only
- The e2-micro instance has limited resources (1 vCPU, 1GB RAM + 1GB swap)
- For production use, consider upgrading to a larger instance
- All data is stored in Docker volumes on the instance
- Regular backups are recommended for production use
- The setup is optimized for development and testing

## 🎯 **Current Deployment Status**

✅ **Successfully Deployed:**

- GCP Project: `carbon-garage-457403-m6`
- Instance IP: `35.202.219.104`
- n8n Access: http://35.202.219.104:5678
- Credentials: admin / admin123
- Status: Running and accessible

## 🤝 **Contributing**

Feel free to submit issues and enhancement requests!

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).
