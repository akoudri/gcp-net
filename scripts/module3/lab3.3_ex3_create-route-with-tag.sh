#!/bin/bash
# Lab 3.3 - Exercice 3.3.3 : Créer la route avec tag
# Objectif : Router sélectivement le trafic via une appliance

set -e

echo "=== Lab 3.3 - Exercice 3 : Créer la route avec tag ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo ""

# Route vers subnet-us via proxy, uniquement pour les VMs avec tag "needs-proxy"
echo "Création de route-via-proxy..."
gcloud compute routes create route-via-proxy \
    --network=$VPC_NAME \
    --destination-range=10.2.0.0/24 \
    --next-hop-instance=proxy-vm \
    --next-hop-instance-zone=${REGION_EU}-b \
    --priority=100 \
    --tags=needs-proxy \
    --description="Route vers US via proxy pour VMs taguées"

echo ""
echo "Route avec tag créée avec succès !"
echo ""

# Vérifier la route
echo "=== Détails de la route ==="
gcloud compute routes describe route-via-proxy
echo ""

echo "Questions à considérer :"
echo "1. Cette route s'applique-t-elle à client2 ? Pourquoi ?"
echo "2. Sans le tag, quel chemin prend le trafic de client2 vers server ?"
echo ""
