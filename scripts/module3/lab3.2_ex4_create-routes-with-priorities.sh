#!/bin/bash
# Lab 3.2 - Exercice 3.2.4 : Créer des routes avec différentes priorités
# Objectif : Comprendre le mécanisme de priorité des routes

set -e

echo "=== Lab 3.2 - Exercice 4 : Créer des routes avec différentes priorités ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"
export REGION_US="us-central1"

echo "VPC : $VPC_NAME"
echo ""

# Route vers 10.99.0.0/24 via vm-eu (priorité haute = 100)
echo "Création de route-specific (priorité 100)..."
gcloud compute routes create route-specific \
    --network=$VPC_NAME \
    --destination-range=10.99.0.0/24 \
    --next-hop-instance=vm-eu \
    --next-hop-instance-zone=${REGION_EU}-b \
    --priority=100 \
    --description="Route spécifique vers 10.99.0.0/24"

echo ""
echo "Création de route-broad (priorité 1000)..."
# Route vers 10.99.0.0/16 via vm-us (priorité basse = 1000)
gcloud compute routes create route-broad \
    --network=$VPC_NAME \
    --destination-range=10.99.0.0/16 \
    --next-hop-instance=vm-us \
    --next-hop-instance-zone=${REGION_US}-a \
    --priority=1000 \
    --description="Route large vers 10.99.0.0/16"

echo ""
echo "Routes créées avec succès !"
echo ""

# Vérifier les routes créées
echo "=== Routes personnalisées ==="
gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange~10.99" \
    --format="table(name,destRange,nextHopInstance,priority)"
echo ""

echo "Questions à considérer :"
echo "1. Un paquet vers 10.99.0.50 utilisera quelle route ? Pourquoi ?"
echo "2. Un paquet vers 10.99.1.50 utilisera quelle route ? Pourquoi ?"
echo ""
