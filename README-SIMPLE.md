# 🚀 Simple n8n Deployment

Methods to quickly deploy n8n with minimal configuration.

## 🎯 **3 Simple Deployment Methods**

### **Method 1: Local Docker Compose (Simplest)**

```bash
# 1. Run Docker Compose
docker-compose up -d

# 2. Access n8n
# http://localhost:5678
```

### **Method 2: GCP Single Command Deployment (Recommended)**

```bash
# 1. Set environment variables
export GCP_PROJECT_ID=your-project-id

# 2. Run deployment
./one-command-deploy.sh

# 3. Access with output IP
# http://[IP]:5678
```

### **Method 3: GCP Detailed Script Deployment**

```bash
# 1. Set environment variables
export GCP_PROJECT_ID=your-project-id
export GCP_ZONE=us-central1-a

# 2. Run deployment
./simple-n8n-deploy.sh

# 3. Access with output IP
# http://[IP]:5678
```

## 🧹 **Cleanup Methods**

### **Local Cleanup**

```bash
docker-compose down
docker volume rm gcp-n8n-setup_n8n_data
```

### **GCP Cleanup**

```bash
gcloud compute instances delete n8n-simple --zone=us-central1-a --project=$GCP_PROJECT_ID
gcloud compute firewall-rules delete allow-n8n --project=$GCP_PROJECT_ID
```

## 📋 **Requirements**

### **Local Execution**

- Docker
- Docker Compose

### **GCP Deployment**

- Google Cloud SDK (gcloud)
- GCP project
- Compute Engine API enabled

## 🔒 **Security Considerations**

Current configuration is for **development/testing**. For production use, add:

- SSL certificates (Let's Encrypt)
- Domain configuration
- Firewall rule restrictions
- Backup strategy
- Monitoring

## 🆚 **Complex vs Simple Configuration Comparison**

| Category        | Complex Configuration | Simple Configuration |
| --------------- | --------------------- | -------------------- |
| **File Count**  | 15+ files             | 3-4 files            |
| **Deploy Time** | 10-15 minutes         | 2-3 minutes          |
| **Complexity**  | High                  | Low                  |
| **Maintenance** | Difficult             | Easy                 |
| **Features**    | Full production       | Basic features       |

## 🎉 **Conclusion**

**Quick testing/development**: Method 1 (Local Docker)
**Simple cloud deployment**: Method 2 (Single command)
**Detailed control**: Method 3 (Detailed script)

Instead of the complex Terraform + Ansible + GitHub Actions configuration, using the simple methods above can **reduce complexity by 90%** while quickly building n8n.
