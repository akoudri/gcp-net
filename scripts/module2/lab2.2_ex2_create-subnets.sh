#!/bin/bash
# Lab 2.2 - Exercice 2.2.2 : Créer les sous-réseaux régionaux
# Objectif : Configurer des sous-réseaux dans plusieurs régions

set -e

echo "=== Lab 2.2 - Exercice 2 : Créer les sous-réseaux régionaux ==="
echo ""

# Variables
export VPC_NAME="production-vpc"

# Sous-réseau Europe (Belgique)
echo "Création du sous-réseau Europe..."
gcloud compute networks subnets create subnet-eu \
    --network=$VPC_NAME \
    --region=europe-west1 \
    --range=10.1.0.0/24 \
    --description="Sous-réseau production Europe"

echo ""

# Sous-réseau US (Iowa)
echo "Création du sous-réseau US..."
gcloud compute networks subnets create subnet-us \
    --network=$VPC_NAME \
    --region=us-central1 \
    --range=10.2.0.0/24 \
    --description="Sous-réseau production US"

echo ""
echo "Sous-réseaux créés avec succès !"
echo ""

# Vérifier les sous-réseaux créés
echo "=== Sous-réseaux du VPC ==="
gcloud compute networks subnets list --network=$VPC_NAME
echo ""

# Examiner les routes créées automatiquement
echo "=== Routes automatiques ==="
gcloud compute routes list --filter="network=$VPC_NAME"
echo ""

echo "Questions à considérer :"
echo "1. Combien de routes ont été créées automatiquement ?"
echo "2. Quelle est la destination de la route par défaut ?"
echo "3. Comment les routes de sous-réseaux permettent-elles la communication inter-régions ?"
