# n8n Infrastructure Provisioning with Terraform, Ansible, and GitHub Actions

This project automates the deployment of an n8n instance on Google Cloud Platform (GCP) using Terraform for infrastructure provisioning and Ansible for server configuration. The entire process is managed through a CI/CD pipeline powered by GitHub Actions.

## Features

- **Automated Infrastructure Provisioning:** Creates a GCP Compute Engine instance, firewall rules, and a static IP address using Terraform.
- **Automated Configuration:** Installs and configures n8n, Docker, Nginx (as a reverse proxy), and Certbot (for SSL) using Ansible.
- **CI/CD Pipeline:** A GitHub Actions workflow automates the entire deployment process.
- **Secure Setup:** Uses a dedicated service account and configures HTTPS with a free SSL certificate from Let's Encrypt.

## Prerequisites

1.  **GCP Account:** A GCP account with billing enabled and the Compute Engine API activated.
2.  **Domain Name:** A registered domain name (e.g., `techcloudup.com` from Namecheap).
3.  **GitHub Repository:** A GitHub repository to host the project code and run Actions.

## Setup Instructions

### 1. Configure GCP

#### a. Create a Service Account

1.  Go to the [GCP Console](https://console.cloud.google.com/).
2.  Navigate to **IAM & Admin > Service Accounts**.
3.  Click **+ CREATE SERVICE ACCOUNT**.
4.  Enter a name (e.g., `github-actions-n8n`) and a description.
5.  Click **CREATE AND CONTINUE**.
6.  Grant the following roles:
    - `Compute Admin`
    - `Service Account User`
7.  Click **CONTINUE**, then **DONE**.

#### b. Create a Service Account Key

1.  Find the newly created service account in the list.
2.  Click the three-dot menu under **Actions** and select **Manage keys**.
3.  Click **ADD KEY > Create new key**.
4.  Select **JSON** as the key type and click **CREATE**. A JSON key file will be downloaded.

### 2. Configure GitHub Repository

#### a. Add Repository Secrets

1.  Go to your GitHub repository's **Settings > Secrets and variables > Actions**.
2.  Click **New repository secret** to add the following secrets:

    -   **`GCP_PROJECT_ID`**: Your GCP Project ID (e.g., `n8n-project`).
    -   **`GCP_CREDENTIALS`**: The entire content of the JSON key file you downloaded.
    -   **`DOMAIN_NAME`**: The subdomain you will use (e.g., `n8n.techcloudup.com`).

#### b. Generate SSH Keys

You need an SSH key pair to allow Ansible to connect to the newly created GCP instance.

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ./n8n-ssh-key -N ""
```

This command creates `n8n-ssh-key` (private key) and `n8n-ssh-key.pub` (public key) in your local directory.

#### c. Add SSH Keys as Secrets

1.  Add the following secrets to your GitHub repository:
    -   **`SSH_PRIVATE_KEY`**: The content of the `n8n-ssh-key` file.
    -   **`SSH_PUBLIC_KEY`**: The content of the `n8n-ssh-key.pub` file.

### 3. Configure Your Domain (Namecheap)

1.  Log in to your Namecheap account.
2.  Go to your domain's **Advanced DNS** settings.
3.  After the Terraform pipeline runs for the first time, it will output a static IP address. Create a new **A Record**:
    -   **Host:** `n8n` (or the subdomain part of your `DOMAIN_NAME`)
    -   **Value:** The static IP address obtained from the Terraform output.
    -   **TTL:** Automatic or 30 min.

## How It Works

1.  **Trigger:** Pushing changes to the `main` branch triggers the GitHub Actions workflow.
2.  **Terraform Deploy:**
    -   The workflow authenticates with GCP using the service account credentials.
    -   Terraform initializes, plans, and applies the infrastructure changes defined in the `.tf` files.
    -   It creates a VM instance, a static IP, and firewall rules.
    -   The public IP of the new instance is saved as an artifact.
3.  **Ansible Configure:**
    -   This job waits for the Terraform job to complete.
    -   It downloads the IP address artifact.
    -   It uses Ansible to connect to the new instance via SSH.
    -   The Ansible playbook (`ansible/playbook.yml`) runs to:
        -   Install Docker and other dependencies.
        -   Set up a 1GB swap file.
        -   Deploy n8n via Docker Compose.
        -   Install and configure Nginx as a reverse proxy.
        -   Obtain and install a Let's Encrypt SSL certificate using Certbot.

Your n8n instance will be available at `https://<your-domain-name>`.

<!-- Re-triggering deployment -->