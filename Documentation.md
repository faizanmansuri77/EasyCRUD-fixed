# EasyCRUD Deployment Documentation (AWS EC2 + MariaDB + Docker)

This guide explains how to deploy the [EasyCRUD-fixed Repository](https://github.com/faizanmansuri77/EasyCRUD-fixed?utm_source=chatgpt.com) application on AWS using:

* EC2 Instance (`c7i-flex.large`)
* MariaDB RDS Database
* Docker & Docker Compose

---

# Architecture

* **Frontend** → React/Vite
* **Backend** → Spring Boot
* **Database** → MariaDB (AWS RDS)
* **Deployment** → Docker Compose on Ubuntu EC2

---

# 1. Launch AWS EC2 Instance

## EC2 Configuration

| Setting       | Value               |
| ------------- | ------------------- |
| Instance Type | `c7i-flex.large`    |
| OS            | Ubuntu Server 22.04 |
| Storage       | 20 GB               |
| Public IP     | Enabled             |

---

## Security Group Inbound Rules

Allow the following inbound ports:

| Type         | Port |
| ------------ | ---- |
| SSH          | 22   |
| HTTP         | 80   |
| Custom TCP   | 3000 |
| Custom TCP   | 8080 |
| MySQL/Aurora | 3306 |

For testing purposes, you can temporarily allow:

```text
0.0.0.0/0
```

---

# 2. Connect to EC2

```bash
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

---

# 3. Install Docker

Update packages:

```bash
sudo apt update
```

Install Docker:

```bash
sudo apt install docker.io -y
```

Enable Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify Docker:

```bash
docker --version
```

---

# 4. Install Docker Compose

```bash
sudo apt install docker-compose -y
```

Verify:

```bash
docker-compose --version
```

---

# 5. Add User to Docker Group

```bash
sudo usermod -aG docker ubuntu
newgrp docker
```

Verify:

```bash
docker ps
```

---

# 6. Install MariaDB Client

```bash
sudo apt install mariadb-client -y
```

---

# 7. Create AWS RDS MariaDB Database

## RDS Configuration

| Setting       | Value        |
| ------------- | ------------ |
| Engine        | MariaDB      |
| DB Name       | `student_db` |
| Username      | `admin`      |
| Password      | `redhat123`  |
| Public Access | Yes          |

---

## RDS Security Group

Allow inbound port:

| Port | Source    |
| ---- | --------- |
| 3306 | 0.0.0.0/0 |

---

# 8. Connect to MariaDB

```bash
mysql -h YOUR_RDS_ENDPOINT -u admin -p
```

Enter password:

```text
redhat123
```

---

# 9. Create Database

```sql
CREATE DATABASE student_db;
```

Use database:

```sql
USE student_db;
```

---

# 10. Create Students Table

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

---

# 11. Clone Repository

Clone project:

```bash
git clone https://github.com/faizanmansuri77/EasyCRUD-fixed.git
```

Go inside project:

```bash
cd EasyCRUD-fixed
```

---

# 12. Update Backend Configuration

Open backend configuration file:

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

Save file.

---

# 13. Update Frontend API URL

Open frontend config file:

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
```

Save file.

---

# 14. Build and Start Containers

Run Docker Compose:

```bash
docker-compose up -d
```

Check running containers:

```bash
docker ps
```

---

# 15. Access Application

Frontend:

```text
http://YOUR_EC2_PUBLIC_IP:3000
```

Backend API:

```text
http://YOUR_EC2_PUBLIC_IP:8080/api
```

---
