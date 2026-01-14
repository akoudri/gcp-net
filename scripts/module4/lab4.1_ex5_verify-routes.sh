#!/bin/bash
# Lab 4.1 - Exercice 4.1.5 : Vérifier les routes échangées
# Objectif : Observer les routes créées automatiquement par le peering

set -e

echo "=== Lab 4.1 - Exercice 5 : Vérifier les routes échangées ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"

echo "Vérification des routes échangées via le peering..."
echo ""

# Voir les routes dans VPC Alpha (inclut maintenant les routes de VPC Beta)
echo "=== Routes dans VPC Alpha ==="
gcloud compute routes list --filter="network=$VPC_ALPHA"
echo ""

# Voir les routes dans VPC Beta
echo "=== Routes dans VPC Beta ==="
gcloud compute routes list --filter="network=$VPC_BETA"
echo ""

# Détails du peering Alpha
echo "=== Détails du peering Alpha vers Beta ==="
gcloud compute networks peerings describe peering-alpha-to-beta \
    --network=$VPC_ALPHA
echo ""

# Détails du peering Beta
echo "=== Détails du peering Beta vers Alpha ==="
gcloud compute networks peerings describe peering-beta-to-alpha \
    --network=$VPC_BETA
echo ""

echo "Questions à considérer :"
echo "1. Quelles nouvelles routes apparaissent après le peering ?"
echo "2. Quel est le next-hop de ces routes ?"
echo "3. Les routes personnalisées sont-elles échangées par défaut ?"
