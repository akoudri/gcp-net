#!/bin/bash
# Lab 2.7 - Déploiement complet : Architecture entreprise
# Objectif : Déployer une architecture VPC complète multi-tiers

set -e

echo "=== Lab 2.7 : Architecture entreprise complète ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="europe-west1-b"
export VPC_NAME="startup-vpc"

echo "Projet : $PROJECT_ID"
echo "Région : $REGION"
echo "VPC : $VPC_NAME"
echo ""

echo "=== Création du VPC ==="
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

echo ""
echo "=== Création des sous-réseaux ==="

# Production Frontend
gcloud compute networks subnets create subnet-prod-frontend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.10.0.0/24 \
    --description="Production - Tier Frontend"

# Production Backend
gcloud compute networks subnets create subnet-prod-backend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.10.1.0/24 \
    --description="Production - Tier Backend"

# Développement
gcloud compute networks subnets create subnet-dev \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.20.0.0/24 \
    --description="Environnement de développement"

# Management (Bastion)
gcloud compute networks subnets create subnet-mgmt \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.30.0.0/24 \
    --description="Management - Bastion et outils"

echo ""
echo "=== Configuration Cloud NAT pour accès sortant ==="

# Créer un Cloud Router (requis pour Cloud NAT)
gcloud compute routers create router-nat \
    --network=$VPC_NAME \
    --region=$REGION

# Configurer Cloud NAT
gcloud compute routers nats create nat-config \
    --router=router-nat \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "=== Création des règles de pare-feu ==="

# SSH vers bastion uniquement (via IAP)
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap-ssh \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=bastion \
    --description="SSH via IAP vers bastion"

# SSH depuis bastion vers toutes les VMs
gcloud compute firewall-rules create ${VPC_NAME}-allow-bastion-ssh \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-tags=bastion \
    --description="SSH depuis bastion"

# HTTP/HTTPS vers frontend prod
gcloud compute firewall-rules create ${VPC_NAME}-allow-web \
    --network=$VPC_NAME \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web \
    --description="Trafic web vers frontend"

# Communication frontend -> backend
gcloud compute firewall-rules create ${VPC_NAME}-allow-frontend-to-backend \
    --network=$VPC_NAME \
    --allow=tcp:8080 \
    --source-tags=frontend \
    --target-tags=backend \
    --description="Frontend vers Backend API"

# ICMP interne (pour debug)
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal-icmp \
    --network=$VPC_NAME \
    --allow=icmp \
    --source-ranges=10.0.0.0/8 \
    --description="Ping interne"

echo ""
echo "=== Création des VMs ==="

# Bastion
gcloud compute instances create bastion \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-mgmt \
    --tags=bastion \
    --image-family=debian-11 \
    --image-project=debian-cloud

# Web Prod (Frontend)
gcloud compute instances create web-prod \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-prod-frontend \
    --tags=web,frontend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx
        echo "Frontend Production" > /var/www/html/index.html'

# API Prod (Backend)
gcloud compute instances create api-prod \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-prod-backend \
    --tags=backend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y python3
        echo "from http.server import HTTPServer, BaseHTTPRequestHandler
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b\"API Backend OK\")
HTTPServer((\"0.0.0.0\", 8080), Handler).serve_forever()" > /tmp/api.py
        python3 /tmp/api.py &'

# Dev VM
gcloud compute instances create dev-vm \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dev \
    --tags=dev \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "=== Résumé ==="
gcloud compute instances list --filter="network:$VPC_NAME"

echo ""
echo "Déploiement terminé avec succès !"
echo ""
echo "Architecture déployée :"
echo "  - 4 sous-réseaux (prod-frontend, prod-backend, dev, mgmt)"
echo "  - 4 VMs (bastion, web-prod, api-prod, dev-vm)"
echo "  - Cloud NAT configuré pour accès sortant"
echo "  - Règles de pare-feu avec principe du moindre privilège"
echo ""
echo "Accès : gcloud compute ssh bastion --zone=$ZONE --tunnel-through-iap"
