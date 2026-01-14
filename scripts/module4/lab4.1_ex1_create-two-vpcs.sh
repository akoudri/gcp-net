#!/bin/bash
# Lab 4.1 - Exercice 4.1.1 : Créer les deux VPC
# Objectif : Créer deux VPC pour le lab VPC Peering

set -e

echo "=== Lab 4.1 - Exercice 1 : Créer les deux VPC ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC Alpha : $VPC_ALPHA"
echo "VPC Beta : $VPC_BETA"
echo "Région : $REGION"
echo ""

# Créer VPC Alpha
echo "Création du VPC Alpha..."
gcloud compute networks create $VPC_ALPHA \
    --subnet-mode=custom \
    --description="VPC Alpha pour peering lab"

gcloud compute networks subnets create subnet-alpha \
    --network=$VPC_ALPHA \
    --region=$REGION \
    --range=10.10.1.0/24

echo ""
echo "VPC Alpha créé avec succès !"
echo ""

# Créer VPC Beta
echo "Création du VPC Beta..."
gcloud compute networks create $VPC_BETA \
    --subnet-mode=custom \
    --description="VPC Beta pour peering lab"

gcloud compute networks subnets create subnet-beta \
    --network=$VPC_BETA \
    --region=$REGION \
    --range=10.20.1.0/24

echo ""
echo "VPC Beta créé avec succès !"
echo ""

# Vérifier
echo "=== Liste des VPC ==="
gcloud compute networks list
echo ""

echo "Questions à considérer :"
echo "1. Combien de sous-réseaux le VPC Alpha possède-t-il ?"
echo "2. Quelle est la plage IP du sous-réseau Beta ?"
echo "3. Quel est le mode de routage BGP par défaut ?"
