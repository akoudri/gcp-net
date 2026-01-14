#!/bin/bash
# Lab 6.1 - Exercice 6.1.2 : Configurer Cloud NAT
# Objectif : Configurer Cloud NAT pour l'accès Internet sortant

set -e

echo "=== Lab 6.1 - Exercice 2 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer un Cloud Router
echo "Création du Cloud Router..."
gcloud compute routers create router-nat-dns \
    --network=$VPC_NAME \
    --region=$REGION
echo ""

# Configurer Cloud NAT pour l'accès Internet sortant
echo "Configuration de Cloud NAT..."
gcloud compute routers nats create nat-dns-lab \
    --router=router-nat-dns \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
echo ""

echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Vérification du Cloud Router ==="
gcloud compute routers describe router-nat-dns --region=$REGION
echo ""

echo "=== Vérification de Cloud NAT ==="
gcloud compute routers nats describe nat-dns-lab \
    --router=router-nat-dns \
    --region=$REGION
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi Cloud NAT est-il nécessaire pour les VMs sans IP publique ?"
echo "2. Quelle est la différence entre Cloud NAT et une passerelle NAT traditionnelle ?"
echo "3. Comment Cloud NAT gère-t-il la scalabilité automatique ?"
