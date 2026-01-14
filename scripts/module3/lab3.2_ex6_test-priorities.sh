#!/bin/bash
# Lab 3.2 - Exercice 3.2.6 : Tester les priorités avec même destination
# Objectif : Comprendre comment les priorités départagent les routes

set -e

echo "=== Lab 3.2 - Exercice 6 : Tester les priorités avec même destination ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_US="us-central1"

echo "VPC : $VPC_NAME"
echo ""

# Créer une deuxième route vers 10.99.0.0/24 avec priorité plus basse
echo "Création de route-specific-backup (priorité 500)..."
gcloud compute routes create route-specific-backup \
    --network=$VPC_NAME \
    --destination-range=10.99.0.0/24 \
    --next-hop-instance=vm-us \
    --next-hop-instance-zone=${REGION_US}-a \
    --priority=500 \
    --description="Route backup vers 10.99.0.0/24"

echo ""
echo "Route backup créée."
echo ""

# Lister les routes vers 10.99.0.0/24
echo "=== Routes vers 10.99.0.0/24 ==="
gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=10.99.0.0/24" \
    --format="table(name,destRange,nextHopInstance,priority)"
echo ""

echo "La route avec priorité 100 (route-specific) gagne sur celle avec priorité 500."
echo ""
echo "Questions à considérer :"
echo "1. Si on supprime route-specific, quelle route sera utilisée pour 10.99.0.50 ?"
echo "2. Deux routes avec même destination ET même priorité : que se passe-t-il ?"
echo ""
