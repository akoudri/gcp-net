#!/bin/bash
# Lab 3.5 - Exercice 3.5.3 : Configurer Cloud NAT
# Objectif : Activer Cloud NAT pour permettre l'accès Internet sortant

set -e

echo "=== Lab 3.5 - Exercice 3 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION_EU"
echo ""

# Créer un Cloud Router (requis pour Cloud NAT)
echo "Création du Cloud Router nat-router..."
gcloud compute routers create nat-router \
    --network=$VPC_NAME \
    --region=$REGION_EU

echo ""
echo "Configuration de Cloud NAT..."
# Configurer Cloud NAT
gcloud compute routers nats create my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging \
    --log-filter=ALL

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration Cloud NAT ==="
gcloud compute routers nats describe my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU
echo ""
