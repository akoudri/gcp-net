#!/bin/bash
# Lab 4.6 - Exercice 4.6.3 : Configurer Cloud NAT pour l'accès sortant
# Objectif : Configurer Cloud NAT pour permettre l'accès Internet sortant

set -e

echo "=== Lab 4.6 - Exercice 3 : Configurer Cloud NAT pour l'accès sortant ==="
echo ""

# Variables
export VPC_SHARED="shared-vpc-sim"
export REGION="europe-west1"

echo "VPC : $VPC_SHARED"
echo "Région : $REGION"
echo ""

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router..."
gcloud compute routers create router-nat-shared \
    --network=$VPC_SHARED \
    --region=$REGION

echo ""

# Configurer Cloud NAT pour permettre l'accès Internet sortant
echo "Configuration de Cloud NAT..."
gcloud compute routers nats create nat-shared-vpc \
    --router=router-nat-shared \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration Cloud NAT ==="
gcloud compute routers nats describe nat-shared-vpc \
    --router=router-nat-shared \
    --region=$REGION

echo ""

echo "Questions à considérer :"
echo "1. Pourquoi configurer Cloud NAT avant de déployer les VMs sans IP externe ?"
echo "2. Dans un vrai Shared VPC, quelle équipe serait responsable de la configuration Cloud NAT ?"
echo "3. Les VMs peuvent-elles recevoir du trafic entrant depuis Internet via Cloud NAT ?"
