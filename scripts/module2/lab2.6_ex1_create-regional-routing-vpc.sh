#!/bin/bash
# Lab 2.6 - Exercice 2.6.1 : Créer un VPC avec routage régional
# Objectif : Comprendre le mode de routage régional

set -e

echo "=== Lab 2.6 - Exercice 1 : VPC avec routage régional ==="
echo ""

# VPC avec routage régional
echo "Création du VPC avec routage régional..."
gcloud compute networks create vpc-regional \
    --subnet-mode=custom \
    --bgp-routing-mode=regional

echo ""

# Sous-réseaux dans deux régions
echo "Création du sous-réseau Europe..."
gcloud compute networks subnets create subnet-eu-regional \
    --network=vpc-regional \
    --region=europe-west1 \
    --range=10.60.0.0/24

echo ""

echo "Création du sous-réseau US..."
gcloud compute networks subnets create subnet-us-regional \
    --network=vpc-regional \
    --region=us-central1 \
    --range=10.61.0.0/24

echo ""

# Vérifier le mode de routage
echo "=== Mode de routage configuré ==="
gcloud compute networks describe vpc-regional \
    --format="get(routingConfig.routingMode)"

echo ""
echo "VPC avec routage régional créé avec succès !"
