#!/bin/bash
# Lab 3.7 - Exercice 3.7.1 : Créer une zone DNS privée
# Objectif : Créer une zone DNS privée pour résolution interne

set -e

echo "=== Lab 3.7 - Exercice 1 : Créer une zone DNS privée ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Créer une zone privée
echo "Création de la zone DNS privée internal-zone..."
gcloud dns managed-zones create internal-zone \
    --description="Zone DNS interne" \
    --dns-name="internal.lab." \
    --visibility=private \
    --networks=$VPC_NAME

echo ""
echo "Zone DNS privée créée avec succès !"
echo ""

# Vérifier la création
echo "=== Détails de la zone ==="
gcloud dns managed-zones describe internal-zone
echo ""
