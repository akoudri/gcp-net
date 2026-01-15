#!/bin/bash
# Lab 3.1 - Exercice 3.1.1 : Créer un VPC de test avec sous-réseaux
# Objectif : Explorer la table de routage d'un VPC

set -e

echo "=== Lab 3.1 - Exercice 1 : Créer un VPC de test avec sous-réseaux ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"
export REGION_US="us-central1"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo ""

# Créer le VPC
echo "Création du VPC..."
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=global

echo ""
echo "Création des sous-réseaux..."

# Créer deux sous-réseaux dans différentes régions
gcloud compute networks subnets create routing-subnet-eu \
    --network=$VPC_NAME \
    --region=$REGION_EU \
    --range=10.11.0.0/24

gcloud compute networks subnets create routing-subnet-us \
    --network=$VPC_NAME \
    --region=$REGION_US \
    --range=10.12.0.0/24

echo ""
echo "VPC et sous-réseaux créés avec succès !"
echo ""

# Vérifier la création
echo "=== VPC créé ==="
gcloud compute networks describe $VPC_NAME
echo ""

echo "=== Sous-réseaux créés ==="
gcloud compute networks subnets list --network=$VPC_NAME
echo ""
