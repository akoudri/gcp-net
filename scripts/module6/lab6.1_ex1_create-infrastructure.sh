#!/bin/bash
# Lab 6.1 - Exercice 6.1.1 : Créer l'infrastructure
# Objectif : Créer le VPC et le sous-réseau pour les labs Cloud DNS

set -e

echo "=== Lab 6.1 - Exercice 1 : Créer l'infrastructure ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# Activer l'API Cloud DNS
echo "Activation de l'API Cloud DNS..."
gcloud services enable dns.googleapis.com
echo ""

# Créer le VPC
echo "Création du VPC..."
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --description="VPC pour les labs Cloud DNS"
echo ""

# Créer le sous-réseau
echo "Création du sous-réseau..."
gcloud compute networks subnets create subnet-dns \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.0.0/24
echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8
echo ""

gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20
echo ""

echo "Infrastructure créée avec succès !"
echo ""
echo "=== Vérification ==="
gcloud compute networks describe $VPC_NAME
