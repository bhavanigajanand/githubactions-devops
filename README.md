# 🚀 End-to-End DevOps CI/CD Pipeline

A complete end-to-end DevOps pipeline built from scratch using GitHub Actions, Docker, Kubernetes, Terraform, and AWS EC2.

![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-blue)
![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-blue)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)

---

## 📋 Project Overview

This project demonstrates a complete end-to-end DevOps pipeline. A simple HTML web application is containerized with Docker, infrastructure is provisioned with Terraform on AWS EC2, and the app is deployed to a self-installed Kubernetes cluster — all automated with GitHub Actions CI/CD.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| AWS EC2 | Cloud server (Ubuntu 22.04, t3.medium) |
| Terraform | Infrastructure as Code to provision EC2 |
| AWS S3 + DynamoDB | Remote Terraform state storage and locking |
| Docker | Containerizing the web application |
| Kubernetes | Self-installed cluster with kubeadm (NOT EKS) |
| GitHub Actions | CI/CD automation pipeline |
| Nginx | Web server serving the HTML app |
| Docker Hub | Container image registry |

---

## 📁 Project Structure
```
.
├── .github/
│   └── workflows/
│       └── cicd.yml          # GitHub Actions CI/CD pipeline
├── app/
│   └── index.html            # Web application
├── k8s/
│   ├── deployment.yaml       # Kubernetes deployment manifest
│   └── service.yaml          # Kubernetes service manifest
├── terraform/
│   ├── main.tf               # EC2 instance, key pair, storage
│   ├── providers.tf          # AWS provider + S3 backend
│   ├── security.tf           # Security group rules
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output EC2 public IP
│   └── userdata.sh           # Installs Docker + Kubernetes on EC2
├── Dockerfile                # Docker image definition
└── .gitignore                # Ignores sensitive terraform files
```

---

## 🔄 CI/CD Pipeline Flow
```
Push code to GitHub
        ↓
GitHub Actions triggers
        ↓
Docker image built from Dockerfile
        ↓
Image pushed to Docker Hub
        ↓
k8s manifests copied to EC2 via SCP
        ↓
SSH into EC2
        ↓
kubectl apply → rollout restart
        ↓
App LIVE at http://<EC2-IP>:30080 ✅
```

---

## ☁️ Infrastructure Setup (Terraform)

Infrastructure is provisioned using Terraform with remote state stored in AWS S3 and DynamoDB locking for production-grade reliability.
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Resources created:
- EC2 instance (t3.medium, Ubuntu 22.04, 20GB gp3)
- Security Group (ports 22, 80, 443, 6443, 30080)
- RSA 4096 Key Pair (auto-generated, saved as .pem)
- S3 backend for tfstate
- DynamoDB table for state locking

---

## ⚙️ Kubernetes Setup

Kubernetes is self-installed using kubeadm — NOT managed EKS. The `userdata.sh` script automatically installs and configures everything when the EC2 boots:

- Docker
- kubeadm, kubelet, kubectl (v1.29)
- Calico network plugin
- Single node cluster (master untainted)

---

## 🔐 GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |
| `EC2_HOST` | EC2 public IP address |
| `EC2_USER` | EC2 username (ubuntu) |
| `EC2_SSH_KEY` | Contents of .pem private key |

---

## 🐛 Real Issues Faced & Fixed

| Error | Cause | Fix |
|-------|-------|-----|
| kubeconfig permission denied | admin.conf not readable by ubuntu user | Copied to /home/ubuntu/.kube/config |
| SCP wrong path | k8s files copied to wrong directory | Corrected target path in cicd.yml |
| ImagePullBackOff | Wrong Docker image name | Fixed image name in deployment.yaml |

---

## 🌐 Live App
```
http://<EC2-IP>:30080
```

---

## 👨‍💻 Author

**Bahavani Gajanand**
- GitHub: [@bhavanigajanand](https://github.com/bhavanigajanand)
- LinkedIn: [Bhavani Gajanand](https://linkedin.com/in/bhavanigajanand)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).