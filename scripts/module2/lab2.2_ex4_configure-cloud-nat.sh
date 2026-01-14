#!/bin/bash
# Lab 2.2 - Exercice 2.2.4 : Configurer Cloud NAT pour l'accès sortant
# Objectif : Permettre l'accès Internet sortant sans IP publiques

set -e

echo "=== Lab 2.2 - Exercice 4 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="production-vpc"

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router pour Europe..."
gcloud compute routers create router-nat-eu \
    --network=$VPC_NAME \
    --region=europe-west1

echo ""

echo "Création du Cloud Router pour US..."
gcloud compute routers create router-nat-us \
    --network=$VPC_NAME \
    --region=us-central1

echo ""

# Configurer Cloud NAT pour Europe
echo "Configuration de Cloud NAT pour Europe..."
gcloud compute routers nats create nat-eu \
    --router=router-nat-eu \
    --region=europe-west1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""

# Configurer Cloud NAT pour US
echo "Configuration de Cloud NAT pour US..."
gcloud compute routers nats create nat-us \
    --router=router-nat-us \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration NAT Europe ==="
gcloud compute routers nats list --router=router-nat-eu --region=europe-west1
echo ""

echo "=== Configuration NAT US ==="
gcloud compute routers nats list --router=router-nat-us --region=us-central1
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi utiliser Cloud NAT plutôt que des IPs externes sur les VMs ?"
echo "2. Quel est l'avantage sécuritaire de Cloud NAT ?"
echo "3. Les VMs peuvent-elles recevoir du trafic entrant via Cloud NAT ?"
