#!/bin/bash
# Lab 6.1 - Exercice 6.1.3 : Créer les VMs
# Objectif : Créer les VMs de test pour le lab DNS

set -e

echo "=== Lab 6.1 - Exercice 3 : Créer les VMs ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# VM 1 - Serveur web
echo "Création de VM1 (serveur web)..."
gcloud compute instances create vm1 \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils nginx
        echo "<h1>VM1 - Web Server</h1>" > /var/www/html/index.html'
echo ""

# VM 2 - Serveur applicatif
echo "Création de VM2 (serveur applicatif)..."
gcloud compute instances create vm2 \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.20 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils'
echo ""

# VM 3 - Base de données
echo "Création de VM3 (base de données)..."
gcloud compute instances create db \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.30 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils'
echo ""

echo "VMs créées avec succès !"
echo ""
echo "Attente de 30 secondes pour que les VMs démarrent..."
sleep 30
echo ""

echo "=== Liste des VMs créées ==="
gcloud compute instances list --filter="zone:$ZONE AND name:(vm1 OR vm2 OR db)"
