# EasyCRUD Application Deployment Guide (AWS EC2 + AWS RDS)

## Project Overview

This project contains:

* **Frontend**: React + Vite application
* **Backend**: Spring Boot application
* **Database**: MariaDB/MySQL
* **Containerization**: Docker + Docker Compose

This guide explains:

1. Launching an EC2 instance
2. Installing Docker and Docker Compose
3. Creating an AWS RDS MariaDB database
4. Creating database tables
5. Uploading project files to EC2
6. Updating application configuration files
7. Running the application with Docker Compose
8. Verifying deployment

---

# Architecture

```text
User Browser
     |
     v
Frontend (React + Nginx)
     |
     v
Backend (Spring Boot)
     |
     v
AWS RDS MariaDB Database
```

---

# Prerequisites

Before starting, make sure you have:

* AWS account
* GitHub account
* SSH client (PuTTY or terminal)
* Basic Linux knowledge

---

# Step 1: Launch EC2 Instance

## 1. Open AWS Console

Go to:

* AWS Console
* EC2 Dashboard

---

## 2. Launch New Instance

Click:

```text
Launch Instance
```

---

## 3. Configure Instance

### Name

```text
easycrud-server
```

### AMI

Select:

```text
Ubuntu Server 22.04 LTS
```

### Instance Type

```text
t2.micro
```

### Key Pair

Create or select an existing key pair.

Download the `.pem` file.

Example:

```text
easycrud-key.pem
```

---

## 4. Configure Security Group

Allow these inbound rules:

| Type       | Port | Source    |
| ---------- | ---- | --------- |
| SSH        | 22   | My IP     |
| HTTP       | 80   | 0.0.0.0/0 |
| Custom TCP | 3000 | 0.0.0.0/0 |
| Custom TCP | 8080 | 0.0.0.0/0 |

Then click:

```text
Launch Instance
```

---

# Step 2: Connect to EC2 Instance

## Linux / Mac

Run:

```bash
chmod 400 easycrud-key.pem

ssh -i easycrud-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

---

## Windows (PowerShell)

```powershell
ssh -i easycrud-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

---

# Step 3: Update Ubuntu Packages

Run:

```bash
sudo apt update && sudo apt upgrade -y
```

---

# Step 4: Install Docker

Run:

```bash
sudo apt install docker.io -y
```

Enable Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify:

```bash
docker --version
```

---

# Step 5: Install Docker Compose

Run:

```bash
sudo apt install docker-compose -y
```

Verify:

```bash
docker-compose --version
```

---

# Step 6: Give Docker Permission to Ubuntu User

Run:

```bash
sudo usermod -aG docker ubuntu
```

Apply changes:

```bash
newgrp docker
```

---

# Step 7: Create AWS RDS MariaDB Database

## 1. Open RDS Console

Go to:

```text
AWS Console → RDS
```

Click:

```text
Create Database
```

---

## 2. Select Database Configuration

### Engine Type

Select:

```text
MariaDB
```

### Template

Select:

```text
Free Tier
```

---

## 3. DB Settings

### DB Instance Identifier

```text
student-db
```

### Master Username

```text
admin
```

### Master Password

Example:

```text
StrongPassword123
```

Save this password securely.

---

## 4. Instance Configuration

### DB Instance Class

```text
db.t3.micro
```

---

## 5. Storage

Keep default settings.

---

## 6. Connectivity

### VPC

Use default VPC.

### Public Access

Select:

```text
Yes
```

### Security Group

Create new security group or use existing.

---

## 7. Additional Configuration

### Initial Database Name

```text
student_db
```

Click:

```text
Create Database
```

Wait until database status becomes:

```text
Available
```

---

# Step 8: Configure RDS Security Group

Open:

```text
RDS → Databases → student-db
```

Open attached security group.

Add inbound rule:

| Type         | Port | Source             |
| ------------ | ---- | ------------------ |
| MySQL/Aurora | 3306 | EC2 Security Group |

OR temporarily:

| Type         | Port | Source    |
| ------------ | ---- | --------- |
| MySQL/Aurora | 3306 | 0.0.0.0/0 |

Recommended:

Use EC2 Security Group instead of public access.

---

# Step 9: Get RDS Endpoint

Open:

```text
RDS → Databases → student-db
```

Copy:

```text
Endpoint
```

Example:

```text
student-db.xxxxx.ap-south-1.rds.amazonaws.com
```

---

# Step 10: Install MariaDB Client on EC2

SSH into EC2 and run:

```bash
sudo apt install mariadb-client -y
```

---

# Step 11: Connect to RDS Database

Run:

```bash
mysql -h YOUR_RDS_ENDPOINT -u admin -p
```

Example:

```bash
mysql -h student-db.xxxxx.ap-south-1.rds.amazonaws.com -u admin -p
```

Enter password.

---

# Step 12: Create Database Tables

Once connected to MariaDB:

Select database:

```sql
USE student_db;
```

---

## Create Table

Run:

```sql
CREATE TABLE students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    course VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Verify:

```sql
SHOW TABLES;
```

Exit:

```sql
EXIT;
```

---

# Step 13: Upload Project to EC2

## Option 1: Clone from GitHub (Recommended)

Install Git:

```bash
sudo apt install git -y
```

Clone repository:

```bash
git clone YOUR_GITHUB_REPO_URL
```

Example:

```bash
git clone https://github.com/your-username/EasyCRUD-fixed.git
```

Go inside project:

```bash
cd EasyCRUD-fixed
```

---

## Option 2: Upload ZIP File

Upload using SCP:

```bash
scp -i easycrud-key.pem EasyCRUD-fixed.zip ubuntu@YOUR_EC2_PUBLIC_IP:/home/ubuntu/
```

SSH into server:

```bash
ssh -i easycrud-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

Install unzip:

```bash
sudo apt install unzip -y
```

Extract:

```bash
unzip EasyCRUD-fixed.zip
```

Go inside folder:

```bash
cd EasyCRUD-fixed
```

---

# Step 14: Update Backend Configuration

Open backend configuration file:

```bash
nano backend/src/main/resources/application.properties
```

Current configuration:

```properties
server.port=8080

spring.datasource.url=jdbc:mariadb://database-1.c968ys4yafsw.ap-south-1.rds.amazonaws.com:3306/student_db?sslMode=trust
spring.datasource.username=admin
spring.datasource.password=redhat123

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

---

## Replace with Your RDS Details

Example:

```properties
server.port=8080

spring.datasource.url=jdbc:mariadb://YOUR_RDS_ENDPOINT:3306/student_db?sslMode=trust
spring.datasource.username=admin
spring.datasource.password=YOUR_DATABASE_PASSWORD

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

Save file:

```text
CTRL + X
Y
ENTER
```

---

# Step 15: Update Frontend API URL

Open file:

```bash
nano frontend/src/utils/config.js
```

Current values:

```javascript
'http://13.202.73.32:8080/api'
```

and

```javascript
'http://13.202.73.32:8080'
```

---

## Replace with Your EC2 Public IP

Example:

```javascript
'http://YOUR_EC2_PUBLIC_IP:8080/api'
```

and

```javascript
'http://YOUR_EC2_PUBLIC_IP:8080'
```

Example:

```javascript
'http://54.123.45.67:8080/api'
```

Save file.

---

# Step 16: Review Docker Compose File

Open:

```bash
nano docker-compose.yml
```

Current file:

```yaml
services:
  backend:
    build:
      context: .
      dockerfile: backend/Dockerfile
    container_name: easycrud-backend
    ports:
      - "8080:8080"

  frontend:
    build:
      context: .
      dockerfile: frontend/Dockerfile
    container_name: easycrud-frontend
    ports:
      - "3000:80"
    depends_on:
      - backend
```

No changes are required if ports are correct.

---

# Step 17: Build Docker Containers

Inside project directory run:

```bash
docker-compose build
```

This process may take several minutes.

---

# Step 18: Start Application

Run:

```bash
docker-compose up -d
```

Verify containers:

```bash
docker ps
```

Expected containers:

```text
easycrud-backend
easycrud-frontend
```

---

# Step 19: Check Container Logs

## Backend Logs

```bash
docker logs easycrud-backend
```

## Frontend Logs

```bash
docker logs easycrud-frontend
```

---

# Step 20: Access Application

## Frontend

Open browser:

```text
http://YOUR_EC2_PUBLIC_IP:3000
```

---

## Backend API

```text
http://YOUR_EC2_PUBLIC_IP:8080
```

---

# Step 21: Test Database Connection

Create a student entry from frontend.

Then connect to database:

```bash
mysql -h YOUR_RDS_ENDPOINT -u admin -p
```

Run:

```sql
USE student_db;
SELECT * FROM students;
```

You should see inserted records.

---

# Useful Docker Commands

## Stop Containers

```bash
docker-compose down
```

---

## Restart Containers

```bash
docker-compose restart
```

---

## Rebuild After Changes

```bash
docker-compose up --build -d
```

---

## View Running Containers

```bash
docker ps
```

---

## Remove Unused Docker Data

```bash
docker system prune -a
```

---

# Common Issues and Fixes

## 1. Frontend Cannot Connect to Backend

### Solution

Check:

* EC2 security group allows port 8080
* Frontend config uses correct EC2 IP
* Backend container is running

Verify:

```bash
docker ps
```

---

## 2. Backend Cannot Connect to Database

### Solution

Check:

* RDS endpoint is correct
* Username/password are correct
* RDS security group allows port 3306

Test manually:

```bash
mysql -h YOUR_RDS_ENDPOINT -u admin -p
```

---

## 3. Docker Build Fails

### Solution

Clean Docker cache:

```bash
docker system prune -a
```

Then rebuild:

```bash
docker-compose build
```

---

## 4. Port Already in Use

Check processes:

```bash
sudo lsof -i :3000
sudo lsof -i :8080
```

Kill process if needed.

---

# Recommended Improvements

## 1. Use Environment Variables

Instead of hardcoding database credentials.

---

## 2. Configure Nginx Reverse Proxy

Use:

* Frontend on port 80
* Backend hidden internally

---

## 3. Add SSL Certificate

Use:

```text
Let's Encrypt
```

---

## 4. Use Domain Name

Example:

```text
app.example.com
```

---

# Final Deployment Checklist

## EC2

* [ ] EC2 instance running
* [ ] Security groups configured
* [ ] Docker installed
* [ ] Docker Compose installed

---

## RDS

* [ ] MariaDB created
* [ ] Database created
* [ ] Tables created
* [ ] Port 3306 accessible

---

## Application

* [ ] Backend configuration updated
* [ ] Frontend API URL updated
* [ ] Docker containers running
* [ ] Frontend accessible
* [ ] Database connection working

---

# Application URLs

## Frontend

```text
http://YOUR_EC2_PUBLIC_IP:3000
```

## Backend

```text
http://YOUR_EC2_PUBLIC_IP:8080
```

---

# Conclusion

You have successfully deployed the EasyCRUD application using:

* AWS EC2
* AWS RDS MariaDB
* Docker
* Docker Compose
* React Frontend
* Spring Boot Backend

The application is now fully connected with the AWS cloud database and accessible through your EC2 public IP.
