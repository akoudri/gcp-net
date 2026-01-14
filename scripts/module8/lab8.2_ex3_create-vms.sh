#!/bin/bash
# Lab 8.2 - Exercice 8.2.3 : Créer les VMs
# Objectif : Déployer les VMs avec tags réseau

set -e

echo "=== Lab 8.2 - Exercice 3 : Créer les VMs ==="
echo ""

# Variables
export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# Créer vm-web
echo ">>> Création de vm-web..."
gcloud compute instances create vm-web \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-frontend \
    --tags=web \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y nginx dnsutils netcat-openbsd'

echo ""
echo "vm-web créée avec succès !"
echo ""

# Créer vm-api
echo ">>> Création de vm-api..."
gcloud compute instances create vm-api \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --tags=api \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y dnsutils netcat-openbsd'

echo ""
echo "vm-api créée avec succès !"
echo ""

# Créer vm-db
echo ">>> Création de vm-db..."
gcloud compute instances create vm-db \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-backend \
    --tags=db \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y dnsutils netcat-openbsd'

echo ""
echo "vm-db créée avec succès !"
echo ""

# Lister les VMs créées
echo "=== VMs créées ==="
gcloud compute instances list --filter="name:(vm-web OR vm-api OR vm-db)" \
    --format="table(name,zone,machineType,networkInterfaces[0].networkIP,tags.items)"

echo ""
echo "IMPORTANT : Les VMs vm-api et vm-db n'ont pas d'IP publique."
echo "Elles utiliseront Cloud NAT pour l'accès Internet sortant."
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi vm-web a une IP publique mais pas vm-api et vm-db ?"
echo "2. Comment les tags réseau seront-ils utilisés pour les règles de pare-feu ?"
echo "3. Quel est l'avantage de ne pas avoir d'IP publique sur les VMs backend ?"
