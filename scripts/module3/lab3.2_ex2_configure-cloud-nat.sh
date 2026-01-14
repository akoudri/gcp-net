#!/bin/bash
# Lab 3.2 - Exercice 3.2.2 : Configurer Cloud NAT pour l'accès sortant
# Objectif : Permettre aux VMs sans IP externe d'accéder à Internet

set -e

echo "=== Lab 3.2 - Exercice 2 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION_EU"
echo ""

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router..."
gcloud compute routers create router-nat-routes \
    --network=$VPC_NAME \
    --region=$REGION_EU

echo ""
echo "Configuration de Cloud NAT..."
# Configurer Cloud NAT pour Europe
gcloud compute routers nats create nat-routes-eu \
    --router=router-nat-routes \
    --region=$REGION_EU \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration Cloud NAT ==="
gcloud compute routers nats describe nat-routes-eu \
    --router=router-nat-routes \
    --region=$REGION_EU
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi configurer Cloud NAT avant de créer les VMs sans IP externe ?"
echo "2. Cloud NAT permet-il aux VMs de recevoir du trafic entrant depuis Internet ?"
echo "3. Combien d'IPs publiques Cloud NAT alloue-t-il automatiquement ?"
echo ""
