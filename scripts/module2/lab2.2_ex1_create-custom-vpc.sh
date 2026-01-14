#!/bin/bash
# Lab 2.2 - Exercice 2.2.1 : Créer le VPC en mode custom
# Objectif : Créer un VPC personnalisé multi-régions

set -e

echo "=== Lab 2.2 - Exercice 1 : Créer un VPC custom ==="
echo ""

# Variables
export VPC_NAME="production-vpc"
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo ""

# Créer le VPC en mode custom
echo "Création du VPC en mode custom..."
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --description="VPC de production multi-régions"

echo ""
echo "VPC créé avec succès !"
echo ""

# Vérifier la création
echo "=== Détails du VPC ==="
gcloud compute networks describe $VPC_NAME
echo ""

echo "Questions à considérer :"
echo "1. Quelle est la différence entre --subnet-mode=auto et --subnet-mode=custom ?"
echo "2. Pourquoi choisir le mode regional pour le routage BGP dans ce cas ?"
