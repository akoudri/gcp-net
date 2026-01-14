#!/bin/bash
# Lab 8.2 - Exercice 8.2.2 : Configurer Cloud NAT
# Objectif : Permettre l'accès Internet sortant pour les VMs sans IP publique

set -e

echo "=== Lab 8.2 - Exercice 2 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer un Cloud Router
echo ">>> Création du Cloud Router..."
gcloud compute routers create router-nat-security \
    --network=$VPC_NAME \
    --region=$REGION

echo ""
echo "Cloud Router créé avec succès !"
echo ""

# Configurer Cloud NAT
echo ">>> Configuration de Cloud NAT..."
gcloud compute routers nats create nat-security \
    --router=router-nat-security \
    --region=$REGION \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges \
    --enable-logging

echo ""
echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration Cloud NAT
echo "=== Vérification de la configuration ==="
echo ""
echo ">>> Configuration Cloud NAT..."
gcloud compute routers nats describe nat-security \
    --router=router-nat-security \
    --region=$REGION

echo ""
echo ">>> Configuration Cloud Router..."
gcloud compute routers describe router-nat-security \
    --region=$REGION

echo ""
echo "Questions pédagogiques :"
echo "1. Pourquoi Cloud NAT est-il nécessaire pour les VMs sans IP publique ?"
echo "2. Quelle est la différence entre --nat-all-subnet-ip-ranges et --nat-custom-subnet-ip-ranges ?"
echo "3. Comment Cloud NAT améliore-t-il la sécurité par rapport aux IP publiques sur chaque VM ?"
