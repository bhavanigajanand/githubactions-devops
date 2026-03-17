#!/bin/bash

# ============================================
# STEP 1: System Update
# ============================================
apt-get update -y
apt-get upgrade -y

# ============================================
# STEP 2: Install Docker
# ============================================
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Allow ubuntu user to run docker without sudo
usermod -aG docker ubuntu

# ============================================
# STEP 3: Install Kubernetes (kubeadm, kubelet, kubectl)
# ============================================

# Turn off swap (Kubernetes requirement)
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load required kernel modules
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Set required sysctl params
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Add Kubernetes apt repository
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | \
tee /etc/apt/sources.list.d/kubernetes.list

# Install kubeadm, kubelet, kubectl
apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# ============================================
# STEP 4: Configure containerd for Kubernetes
# ============================================
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# ============================================
# STEP 5: Initialize Kubernetes Cluster
# ============================================
kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all

# Setup kubeconfig for ubuntu user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Also setup for root
export KUBECONFIG=/etc/kubernetes/admin.conf

# ============================================
# STEP 6: Install Calico Network Plugin
# ============================================
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f \
https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# ============================================
# STEP 7: Allow pods on master node (single node cluster)
# ============================================
kubectl --kubeconfig=/etc/kubernetes/admin.conf taint nodes --all \
node-role.kubernetes.io/control-plane-

# ============================================
# STEP 8: Copy k8s manifests to ubuntu home
# ============================================
mkdir -p /home/ubuntu/k8s
chown -R ubuntu:ubuntu /home/ubuntu/k8s

echo "✅ Setup Complete! Docker + Kubernetes are ready."