#!/bin/bash
# Lab 6.1 - Exercice 6.1.4 : Créer la zone DNS privée
# Objectif : Créer une zone DNS privée pour le lab

set -e

echo "=== Lab 6.1 - Exercice 4 : Créer la zone DNS privée ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"

echo "VPC : $VPC_NAME"
echo ""

# Créer la zone privée
echo "Création de la zone DNS privée..."
gcloud dns managed-zones create zone-lab-internal \
    --dns-name="lab.internal." \
    --description="Zone DNS privée pour le lab" \
    --visibility=private \
    --networks=$VPC_NAME
echo ""

echo "Zone DNS créée avec succès !"
echo ""

# Vérifier la création
echo "=== Détails de la zone DNS ==="
gcloud dns managed-zones describe zone-lab-internal
echo ""

# Lister les zones
echo "=== Liste des zones DNS ==="
gcloud dns managed-zones list
