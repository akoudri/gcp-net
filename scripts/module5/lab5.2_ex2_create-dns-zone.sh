#!/bin/bash
# Lab 5.2 - Exercice 5.2.2 : Créer une zone DNS privée pour googleapis.com
# Objectif : Configurer une zone DNS privée pour contrôler la résolution

set -e

echo "=== Lab 5.2 - Exercice 2 : Créer une zone DNS privée ==="
echo ""

export VPC_NAME="vpc-private-access"

echo "VPC : $VPC_NAME"
echo ""

# Créer la zone DNS privée
echo "Création de la zone DNS privée pour googleapis.com..."
gcloud dns managed-zones create googleapis-private \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=$VPC_NAME \
    --description="Zone privée pour router googleapis.com vers PGA"

echo ""
echo "Zone DNS créée avec succès !"
echo ""

# Vérifier la création
echo "=== Détails de la zone DNS ==="
gcloud dns managed-zones describe googleapis-private

echo ""
echo "=== Zone DNS privée créée ! ==="
echo ""
echo "Cette zone permet de contrôler comment googleapis.com est résolu"
echo "dans le VPC $VPC_NAME."
