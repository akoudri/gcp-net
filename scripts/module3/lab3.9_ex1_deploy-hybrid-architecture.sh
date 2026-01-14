#!/bin/bash
# Lab 3.9 - Exercice 3.9 : Script de déploiement de l'architecture hybride
# Objectif : Déployer une architecture complète combinant tous les concepts du module

set -e

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"
export VPC_NAME="hybrid-vpc"

echo "=== Lab 3.9 - Architecture Hybride Complète ==="
echo ""
echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

echo "=== 1. Création du VPC ==="
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

echo ""
echo "=== 2. Création des sous-réseaux ==="
# Frontend
gcloud compute networks subnets create subnet-frontend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.10.0.0/24 \
    --enable-private-google-access

# Backend
gcloud compute networks subnets create subnet-backend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.20.0.0/24 \
    --enable-private-google-access

echo ""
echo "=== 3. Configuration Cloud NAT ==="
gcloud compute routers create hybrid-router \
    --network=$VPC_NAME \
    --region=$REGION

gcloud compute routers nats create hybrid-nat \
    --router=hybrid-router \
    --region=$REGION \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging

echo ""
echo "=== 4. Règles de pare-feu ==="
# SSH via IAP
gcloud compute firewall-rules create ${VPC_NAME}-allow-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

# Trafic interne
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

# Health checks Google
gcloud compute firewall-rules create ${VPC_NAME}-allow-health-check \
    --network=$VPC_NAME \
    --allow=tcp:80,tcp:443 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22

echo ""
echo "=== 5. Déploiement des VMs ==="
# Web VM
gcloud compute instances create web-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --private-network-ip=10.10.0.10 \
    --no-address \
    --tags=web,frontend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx curl dnsutils
        echo "Web Server: $(hostname)" > /var/www/html/index.html'

# Proxy VM
gcloud compute instances create proxy-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --private-network-ip=10.10.0.100 \
    --no-address \
    --can-ip-forward \
    --tags=proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        apt-get update && apt-get install -y squid tcpdump'

# API VM
gcloud compute instances create api-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --private-network-ip=10.20.0.10 \
    --no-address \
    --tags=api,backend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y python3 curl
        echo "from http.server import HTTPServer, BaseHTTPRequestHandler
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b\"API OK\")
HTTPServer((\"0.0.0.0\", 8080), Handler).serve_forever()" > /tmp/api.py
        python3 /tmp/api.py &'

# DB VM
gcloud compute instances create db-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --private-network-ip=10.20.0.20 \
    --no-address \
    --tags=database,needs-proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "=== 6. Configuration DNS privé ==="
gcloud dns managed-zones create app-internal \
    --description="Zone interne pour l'application" \
    --dns-name="app.internal." \
    --visibility=private \
    --networks=$VPC_NAME

gcloud dns record-sets transaction start --zone=app-internal
gcloud dns record-sets transaction add 10.10.0.10 \
    --name="web.app.internal." --ttl=300 --type=A --zone=app-internal
gcloud dns record-sets transaction add 10.20.0.10 \
    --name="api.app.internal." --ttl=300 --type=A --zone=app-internal
gcloud dns record-sets transaction add 10.20.0.20 \
    --name="db.app.internal." --ttl=300 --type=A --zone=app-internal
gcloud dns record-sets transaction execute --zone=app-internal

echo ""
echo "=== 7. Route personnalisée pour db-vm via proxy ==="
gcloud compute routes create db-outbound-via-proxy \
    --network=$VPC_NAME \
    --destination-range=0.0.0.0/0 \
    --next-hop-instance=proxy-vm \
    --next-hop-instance-zone=$ZONE \
    --priority=100 \
    --tags=needs-proxy

echo ""
echo "=== Déploiement terminé ==="
echo ""
echo "Tests à effectuer :"
echo "1. Se connecter à web-vm et tester: curl api.app.internal:8080"
echo "2. Se connecter à db-vm et vérifier que le trafic passe par proxy-vm"
echo "3. Vérifier l'accès Internet via Cloud NAT depuis toutes les VMs"
echo "4. Tester la résolution DNS interne"
echo ""
