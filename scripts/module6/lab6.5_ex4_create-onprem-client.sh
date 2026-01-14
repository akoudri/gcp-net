#!/bin/bash
# Lab 6.5 - Exercice 6.5.4 : Créer un client "on-premise"
# Objectif : Déployer une VM simulant un client on-premise

set -e

echo "=== Lab 6.5 - Exercice 4 : Créer un client on-premise ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export ZONE="europe-west1-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# VM simulant un client on-premise
echo "Création du client on-premise..."
gcloud compute instances create client-onprem \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-onprem \
    --private-network-ip=10.0.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils'
echo ""

echo "Client on-premise créé avec succès !"
echo ""

# Attendre que la VM démarre
echo "Attente de 30 secondes pour que la VM démarre..."
sleep 30
echo ""

echo "=== Vérification ==="
gcloud compute instances describe client-onprem --zone=$ZONE \
    --format="get(name,networkInterfaces[0].networkIP,status)"
