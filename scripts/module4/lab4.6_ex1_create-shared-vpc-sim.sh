#!/bin/bash
# Lab 4.6 - Exercice 4.6.1 : Créer le VPC "partagé"
# Objectif : Créer un VPC simulant l'architecture Shared VPC sans organisation

set -e

echo "=== Lab 4.6 - Exercice 1 : Créer le VPC 'partagé' ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_SHARED="shared-vpc-sim"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_SHARED"
echo "Région : $REGION"
echo ""

# Créer le VPC (simule le projet hôte)
echo "Création du VPC partagé simulé..."
gcloud compute networks create $VPC_SHARED \
    --subnet-mode=custom \
    --description="VPC partagé simulé"

echo ""

# Sous-réseau frontend
echo "Création du sous-réseau frontend..."
gcloud compute networks subnets create subnet-frontend \
    --network=$VPC_SHARED \
    --region=$REGION \
    --range=10.100.0.0/24 \
    --enable-private-ip-google-access \
    --description="Sous-réseau pour équipe frontend"

echo ""

# Sous-réseau backend
echo "Création du sous-réseau backend..."
gcloud compute networks subnets create subnet-backend \
    --network=$VPC_SHARED \
    --region=$REGION \
    --range=10.100.1.0/24 \
    --enable-private-ip-google-access \
    --description="Sous-réseau pour équipe backend"

echo ""

# Sous-réseau data
echo "Création du sous-réseau data..."
gcloud compute networks subnets create subnet-data \
    --network=$VPC_SHARED \
    --region=$REGION \
    --range=10.100.2.0/24 \
    --enable-private-ip-google-access \
    --description="Sous-réseau pour équipe data"

echo ""
echo "VPC partagé simulé créé avec succès !"
echo ""

# Afficher les sous-réseaux
echo "=== Sous-réseaux créés ==="
gcloud compute networks subnets list --network=$VPC_SHARED
