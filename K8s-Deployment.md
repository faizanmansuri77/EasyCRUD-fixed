# EasyCRUD Production Deployment on AWS EKS

## Architecture Overview

This deployment uses:

* **EC2 Instance** → DevOps/Jenkins workstation
* **Terraform** → Infrastructure provisioning
* **Amazon EKS** → Kubernetes cluster
* **Amazon RDS (MariaDB)** → Database
* **Docker Hub** → Container registry
* **Kubernetes** → Application orchestration
* **Ingress** → External access routing

---

# 1. Launch EC2 Instance

Launch an Ubuntu EC2 instance with:

| Configuration  | Value                                             |
| -------------- | ------------------------------------------------- |
| AMI            | Ubuntu 22.04                                      |
| Instance Type  | t2.large or higher                                |
| Storage        | 25 GB                                             |
| Security Group | Allow 22, 80, 443, 8080                           |
| IAM Role       | AdministratorAccess (recommended for lab/testing) |

Connect to EC2:

```bash
ssh -i your-key.pem ubuntu@YOUR_PUBLIC_IP
```

---

# 2. Clone Project Repository

```bash
git clone https://github.com/faizanmansuri77/EasyCRUD-fixed.git
cd EasyCRUD-fixed
```

---

# 3. Install Required Packages

## Update System

```bash
sudo apt update -y
```

## Install Docker

```bash
sudo apt install docker.io -y
```

Enable Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Add current user to Docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

# 4. Install AWS CLI

```bash
sudo snap install aws-cli --classic
```

Verify:

```bash
aws --version
```

Configure AWS:

```bash
aws configure
```

Provide:

```text
AWS Access Key ID
AWS Secret Access Key
Region: ap-south-1
Output format: json
```

---

# 5. Install Terraform

## Add HashiCorp Repository

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

---

## Update Repository File

```bash
sudo nano /etc/apt/sources.list.d/hashicorp.list
```

Replace with:

```bash
deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main
```

---

## Install Terraform

```bash
sudo apt update -y
sudo apt install terraform -y
```

Verify:

```bash
terraform version
```

---

# 6. Provision Infrastructure Using Terraform

Go to Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Deploy Infrastructure:

```bash
terraform apply --auto-approve
```

Terraform provisions:

* VPC
* Subnets
* Internet Gateway
* Route Tables
* Security Groups
* EKS Cluster
* EKS Node Group
* RDS MariaDB

---

# 7. Configure RDS Database

Install MariaDB client:

```bash
sudo apt install mariadb-client -y
```

Connect to RDS:

```bash
mysql -h YOUR_RDS_ENDPOINT -u admin -p
```

Enter password:

```text
redhat123
```

---

## Create Database

```sql
CREATE DATABASE student_db;
```

Use database:

```sql
USE student_db;
```

---

## Create Students Table

```sql
CREATE TABLE `students` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `course` varchar(255) DEFAULT NULL,
  `student_class` varchar(255) DEFAULT NULL,
  `percentage` double DEFAULT NULL,
  `branch` varchar(255) DEFAULT NULL,
  `mobile_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
```

Exit MySQL:

```sql
EXIT;
```

---

# 8. Configure Backend Application

Open backend configuration:

```bash
nano backend/src/main/resources/application.properties
```

Replace with:

```properties
server.port=8080

spring.datasource.url=jdbc:mariadb://YOUR_RDS_ENDPOINT:3306/student_db?sslMode=trust
spring.datasource.username=admin
spring.datasource.password=redhat123

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

Save and exit.

---

# 9. Install kubectl

Download kubectl:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

Install kubectl:

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Verify:

```bash
kubectl version --client
```

---

# 10. Configure kubectl for EKS

```bash
aws eks update-kubeconfig \
--name easycrud-eks-cluster \
--region ap-south-1
```

Verify cluster:

```bash
kubectl get nodes
```

---

# 11. Build & Push Backend Docker Image

Go to backend directory:

```bash
cd backend
```

Build Docker image:

```bash
docker build -t orionpax77/easycrud-backend:latest .
```

Login to Docker Hub:

```bash
docker login -u orionpax77
```

Push image:

```bash
docker push orionpax77/easycrud-backend:latest
```

---

# 12. Deploy Backend to Kubernetes

Apply Kubernetes manifests:

```bash
kubectl apply -f namespace.yaml
```

```bash
kubectl apply -f backend-configmap.yaml
```

```bash
kubectl apply -f backend-secret.yaml
```

```bash
kubectl apply -f backend-deployment.yaml
```

```bash
kubectl apply -f backend-service.yaml
```

Verify services:

```bash
kubectl get svc -n easycrud
```

Copy the backend service external endpoint.

---

# 13. Configure Frontend API URL

Open frontend config:

```bash
nano frontend/src/utils/config.js
```

Replace with:

```javascript
// Utility to get configuration values from build-time environment variables
export const getConfig = (key, defaultValue = '') => {
  if (import.meta.env[key]) {
    return import.meta.env[key];
  }

  return defaultValue;
};

// Specific getters for common config values
export const getApiUrl = () => {
  const apiUrl = getConfig(
    'VITE_API_URL',
    'http://YOUR_BACKEND_SERVICE_ENDPOINT/api'
  );

  console.log('API URL:', apiUrl);

  return apiUrl;
};

export const getApiBaseUrl = () =>
  getConfig(
    'VITE_API_BASE_URL',
    'http://YOUR_BACKEND_SERVICE_ENDPOINT'
  );

export const getAppTitle = () =>
  getConfig(
    'VITE_APP_TITLE',
    'EasyCRUD Student Registration'
  );
```

Save and exit.

---

# 14. Build & Push Frontend Docker Image

Go to frontend directory:

```bash
cd frontend
```

Build Docker image:

```bash
docker build -t orionpax77/easycrud-frontend:latest .
```

Login to Docker Hub:

```bash
docker login -u orionpax77
```

Push image:

```bash
docker push orionpax77/easycrud-frontend:latest
```

---

# 15. Deploy Frontend to Kubernetes

Apply manifests:

```bash
kubectl apply -f frontend-deployment.yaml
```

```bash
kubectl apply -f frontend-service.yaml
```

```bash
kubectl apply -f ingress.yaml
```

Verify ingress:

```bash
kubectl get ingress
```

---

# 16. Verify Deployment

Check all resources:

```bash
kubectl get all -n easycrud
```

Check ingress:

```bash
kubectl get ingress -n easycrud
```

Access application:

```text
http://INGRESS-EXTERNAL-IP
```

---

# 17. Useful Kubernetes Commands

## View Pods

```bash
kubectl get pods -n easycrud
```

## View Services

```bash
kubectl get svc -n easycrud
```

## View Logs

```bash
kubectl logs deployment/easycrud-backend -n easycrud
```

```bash
kubectl logs deployment/easycrud-frontend -n easycrud
```

## Restart Deployment

```bash
kubectl rollout restart deployment easycrud-backend -n easycrud
```

```bash
kubectl rollout restart deployment easycrud-frontend -n easycrud
```

---

# 18. Cleanup Resources

Destroy Terraform infrastructure:

```bash
cd terraform
terraform destroy --auto-approve
```

---

# Project Repository

* [EasyCRUD-fixed GitHub Repository](https://github.com/faizanmansuri77/EasyCRUD-fixed?utm_source=chatgpt.com)

---

# Deployment Flow Summary

```text
EC2
 ├── Terraform
 │     ├── EKS Cluster
 │     ├── Node Group
 │     └── RDS MariaDB
 │
 ├── Docker Build
 │     ├── Backend Image
 │     └── Frontend Image
 │
 ├── Docker Hub
 │
 └── Kubernetes Deployment
       ├── Backend
       ├── Frontend
       └── Ingress
```
