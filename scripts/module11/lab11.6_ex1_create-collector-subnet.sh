#!/bin/bash
# Lab 11.6 - Exercice 11.6.1 : Créer le sous-réseau pour le collecteur
# Objectif : Créer un sous-réseau dédié pour le collecteur de packets

set -e

echo "=== Lab 11.6 - Exercice 1 : Créer le sous-réseau pour le collecteur ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Sous-réseau pour le collecteur
echo "Création du sous-réseau subnet-collector..."
gcloud compute networks subnets create subnet-collector \
    --network=vpc-observability \
    --region=$REGION \
    --range=10.0.10.0/24

echo ""
echo "Sous-réseau créé avec succès !"
echo ""

# Afficher les détails
echo "=== Détails du sous-réseau ==="
gcloud compute networks subnets describe subnet-collector \
    --region=$REGION

echo ""
echo "Le sous-réseau est prêt pour héberger l'instance collecteur."
