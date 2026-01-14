#!/bin/bash
# Lab 8.2 - Exercice 8.2.1 : Créer l'infrastructure
# Objectif : Créer le VPC et les sous-réseaux pour le lab de sécurité

set -e

echo "=== Lab 8.2 - Exercice 1 : Créer l'infrastructure ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# Créer le VPC
echo ">>> Création du VPC..."
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom

echo ""
echo "VPC créé avec succès !"
echo ""

# Créer les sous-réseaux
echo ">>> Création du sous-réseau frontend..."
gcloud compute networks subnets create subnet-frontend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24

echo ""
echo ">>> Création du sous-réseau backend..."
gcloud compute networks subnets create subnet-backend \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.2.0/24

echo ""
echo "Infrastructure créée avec succès !"
echo ""

# Vérifier les ressources créées
echo "=== Vérification ==="
echo ""
echo "VPC :"
gcloud compute networks describe $VPC_NAME

echo ""
echo "Sous-réseaux :"
gcloud compute networks subnets list --filter="network:$VPC_NAME"

echo ""
echo "Questions à considérer :"
echo "1. Pourquoi utiliser le mode custom plutôt qu'auto ?"
echo "2. Comment choisir les plages CIDR pour les sous-réseaux ?"
echo "3. Quels sont les avantages de la séparation frontend/backend ?"
