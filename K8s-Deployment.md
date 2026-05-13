launch ec2 
then
git clone https://github.com/faizanmansuri77/EasyCRUD-fixed.git
apt update -y
apt install docker.io -y
snap install aws-cli --classic
aws configure

Terraform installation
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
update the repo and install the terraform
sudo nano /etc/apt/sources.list.d/hashicorp.list
deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main
sudo apt update -y
sudo apt install terraform
cd terraform 
terraform init
terraform apply --auto-approve
then 
sudo apt install mariadb-client -y
mysql -h YOUR_RDS_ENDPOINT -u admin -p
Enter password:

redhat123
9. Create Database
CREATE DATABASE student_db;
Use database:

USE student_db;
10. Create Students Table
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

Update Backend Configuration
Open backend configuration file:

nano backend/src/main/resources/application.properties
Replace with:

server.port=8080

spring.datasource.url=jdbc:mariadb://YOUR_RDS_ENDPOINT:3306/student_db?sslMode=trust
spring.datasource.username=admin
spring.datasource.password=redhat123

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
Save file.

Install kubectl
Download the latest release with the command:

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
Install kubectl:

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
Note: If you do not have root access on the target system, you can still install kubectl to the ~/.local/bin directory:

chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
kubectl version --client

aws eks update-kubeconfig --name easycrud-eks-cluster --region ap-south-1 


cd backend 
docker build -t orionpax77/easycrud-backend:latest .
docker login -uorionpax77
docker push orionpax77/easycrud-backend:latest .
kubectl apply -f namespace.yaml
kubectl apply -f backend-configmap.yaml
kubectl apply -f backend-secret.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml


kubectl get svc -n easycrud 
and copy backend-svc 
and update it in
13. Update Frontend API URL
Open frontend config file:

nano frontend/src/utils/config.js
Replace with:

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
    'http://YOUR_EC2_PUBLIC_IP:8080/api'
  );

  console.log('API URL:', apiUrl);

  return apiUrl;
};

export const getApiBaseUrl = () =>
  getConfig(
    'VITE_API_BASE_URL',
    'http://YOUR_EC2_PUBLIC_IP:8080'
  );

export const getAppTitle = () =>
  getConfig(
    'VITE_APP_TITLE',
    'EasyCRUD Student Registration'
  );
Save file.


cd frontend 
docker build -t orionpax77/easycrud-frontend:latest .
docker login -uorionpax77
docker push orionpax77/easycrud-frontend:latest .
then
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f ingress.yaml

kubectl get ingress

