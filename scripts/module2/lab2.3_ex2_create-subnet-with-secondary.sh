#!/bin/bash
# Lab 2.3 - Exercice 2.3.2 : Créer un sous-réseau avec plages secondaires
# Objectif : Configurer des plages secondaires pour GKE

set -e

echo "=== Lab 2.3 - Exercice 2 : Sous-réseau avec plages secondaires ==="
echo ""

# Créer un VPC pour cet exercice
echo "Création du VPC planning-vpc..."
gcloud compute networks create planning-vpc \
    --subnet-mode=custom

echo ""

# Créer un sous-réseau avec plages secondaires (pour GKE)
echo "Création du sous-réseau avec plages secondaires..."
gcloud compute networks subnets create subnet-prod-eu \
    --network=planning-vpc \
    --region=europe-west1 \
    --range=10.10.0.0/20 \
    --secondary-range=pods=10.10.16.0/20,services=10.10.32.0/24 \
    --description="Production Europe avec plages GKE"

echo ""
echo "Sous-réseau créé avec succès !"
echo ""

# Vérifier les plages
echo "=== Configuration des plages IP ==="
gcloud compute networks subnets describe subnet-prod-eu \
    --region=europe-west1 \
    --format="yaml(ipCidrRange,secondaryIpRanges)"

echo ""
echo "Questions à considérer :"
echo "1. À quoi servent les plages secondaires dans le contexte GKE ?"
echo "2. Pourquoi la plage des pods est-elle plus grande que celle des services ?"
