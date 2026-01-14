#!/bin/bash
# Lab 6.5 - Exercice 6.5.3 : Configurer Cloud NAT
# Objectif : Configurer Cloud NAT pour le client on-premise

set -e

echo "=== Lab 6.5 - Exercice 3 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer un Cloud Router (si pas déjà créé)
echo "Création/vérification du Cloud Router..."
gcloud compute routers create router-nat-dns \
    --network=$VPC_NAME \
    --region=$REGION 2>/dev/null || echo "Router déjà existant"
echo ""

# Configurer Cloud NAT pour l'accès Internet sortant
echo "Configuration de Cloud NAT..."
gcloud compute routers nats create nat-dns-inbound \
    --router=router-nat-dns \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips 2>/dev/null || echo "NAT déjà existant ou en cours de configuration"
echo ""

echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Vérification du Cloud Router ==="
gcloud compute routers describe router-nat-dns --region=$REGION
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi le client on-premise a-t-il besoin de Cloud NAT ?"
echo "2. Cloud NAT est-il nécessaire pour l'inbound forwarding DNS lui-même ?"
