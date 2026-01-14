#!/bin/bash
# Lab 3.3 - Exercice 3.3.1 : Configurer Cloud NAT pour l'accès sortant
# Objectif : Configurer Cloud NAT pour les VMs sans IP externe

set -e

echo "=== Lab 3.3 - Exercice 1 : Configurer Cloud NAT pour l'accès sortant ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION_EU"
echo ""

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router..."
gcloud compute routers create router-nat-appliance \
    --network=$VPC_NAME \
    --region=$REGION_EU

echo ""
echo "Configuration de Cloud NAT..."
# Configurer Cloud NAT
gcloud compute routers nats create nat-appliance \
    --router=router-nat-appliance \
    --region=$REGION_EU \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration Cloud NAT ==="
gcloud compute routers nats describe nat-appliance \
    --router=router-nat-appliance \
    --region=$REGION_EU
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi est-il important de configurer Cloud NAT avant de créer des VMs sans IP externe ?"
echo "2. Les VMs avec le tag 'needs-proxy' utiliseront-elles Cloud NAT pour accéder à Internet ?"
echo "3. Quelle est la différence entre router le trafic via une appliance et utiliser Cloud NAT ?"
echo ""
