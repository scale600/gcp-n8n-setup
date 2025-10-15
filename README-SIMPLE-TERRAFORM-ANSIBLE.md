# 🚀 Simple Terraform + Ansible + Docker n8n Deployment

**Terraform → Create GCP Infrastructure**  
**Ansible → Configure Server and Install n8n**  
**Docker → Run n8n Container**  
**Complete! (Access via IP:5678)**

## 🎯 **Simplified Configuration**

### **Removed Complexity**

- ❌ Nginx reverse proxy
- ❌ SSL certificates (Let's Encrypt)
- ❌ Domain configuration
- ❌ Complex firewall rules
- ❌ Complex Ansible tasks

### **Retained Core Features**

- ✅ Terraform for GCP infrastructure management
- ✅ Ansible for server configuration automation
- ✅ Docker for n8n container execution
- ✅ Simple firewall rules (port 5678)
- ✅ Static IP address
- ✅ Remote state management (GCS backend)

## 📁 **File Structure**

```
├── terraform-simple/
│   ├── main.tf          # Simplified Terraform configuration
│   ├── variables.tf     # Variable definitions
│   └── backend.tf       # Terraform state backend configuration
├── ansible-simple/
│   ├── playbook.yml     # Simplified Ansible playbook
│   └── requirements.yml # Ansible collection requirements
├── .github/workflows/
│   └── deploy-simple.yml # Simplified GitHub Actions
├── deploy-simple.sh     # Local deployment script
└── setup-terraform-backend.sh # Backend setup script
```

## 🚀 **Deployment Methods**

### **Method 1: Local Deployment (Recommended)**

```bash
# 1. Set environment variables
export GCP_PROJECT_ID=your-project-id
export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"

# 2. Setup Terraform backend (first time only)
./setup-terraform-backend.sh

# 3. Run deployment
./deploy-simple.sh

# 4. Access after completion
# http://[IP]:5678
```

### **Method 2: GitHub Actions Deployment**

```bash
# 1. Configure GitHub Secrets
# - GCP_PROJECT_ID
# - GCP_CREDENTIALS
# - SSH_PUBLIC_KEY
# - SSH_PRIVATE_KEY

# 2. Run workflow
gh workflow run deploy-simple.yml

# 3. Access after completion
# http://[IP]:5678
```

## 🧹 **Cleanup Methods**

### **Local Cleanup**

```bash
cd terraform-simple
terraform destroy
```

### **GitHub Actions Cleanup**

```bash
# Run terraform destroy in workflow or
# Manually delete resources from GCP console
```

## 📊 **Comparison: Original vs Simplified Configuration**

| Category            | Original Configuration | Simplified Configuration |
| ------------------- | ---------------------- | ------------------------ |
| **Terraform Files** | 3 files                | 2 files                  |
| **Ansible Tasks**   | 20+ tasks              | 8 tasks                  |
| **GitHub Actions**  | 4 workflows            | 1 workflow               |
| **Deployment Time** | 10-15 minutes          | 5-8 minutes              |
| **Complexity**      | High                   | Medium                   |
| **Features**        | Full production        | Core features            |

## 🔧 **Requirements**

### **Local Deployment**

- Terraform
- Ansible
- Google Cloud SDK
- SSH key pair

### **GitHub Actions Deployment**

- GitHub Secrets configuration
- GCP Service Account

## 🎉 **Advantages**

1. **50% complexity reduction**: Removed Nginx, SSL, domain configuration
2. **Faster deployment**: Complete in 5-8 minutes
3. **Gentle learning curve**: Retain only core concepts
4. **Easy maintenance**: Simple structure
5. **Extensible**: Easy to add features when needed
6. **State management**: Remote state storage prevents resource conflicts
7. **Team collaboration**: Shared state enables team deployments

## 🚨 **Considerations**

- **HTTP only**: No SSL (for development/testing)
- **Basic security**: Minimal firewall rules
- **No domain**: Access only via IP address
- **No backup**: Manual backup required

## 🔄 **Extension Methods**

You can add the following features when needed:

```bash
# Add SSL
# - Let's Encrypt certificates
# - Nginx reverse proxy

# Add domain
# - DNS configuration
# - Domain verification

# Enhance security
# - Restrict firewall rules
# - Strengthen SSH key-based authentication
```

## 🎯 **Conclusion**

This configuration is a **balanced approach** that maintains the **core advantages of Terraform + Ansible + Docker** while **removing unnecessary complexity**.

If you want **fast deployment** and **simple maintenance** while enjoying the benefits of **infrastructure as code**, we recommend this method!
