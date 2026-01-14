#!/bin/bash
# Lab 6.4 - Exercice 6.4.1 : Créer un sous-réseau pour le "on-premise"
# Objectif : Créer un sous-réseau simulant le réseau on-premise

set -e

echo "=== Lab 6.4 - Exercice 1 : Créer un sous-réseau pour le on-premise ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Sous-réseau simulant le réseau on-premise
echo "Création du sous-réseau on-premise..."
gcloud compute networks subnets create subnet-onprem \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24
echo ""

echo "Sous-réseau on-premise créé avec succès !"
echo ""

echo "=== Vérification ==="
gcloud compute networks subnets describe subnet-onprem --region=$REGION
