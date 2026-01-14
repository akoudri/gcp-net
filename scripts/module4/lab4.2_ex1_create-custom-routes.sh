#!/bin/bash
# Lab 4.2 - Exercice 4.2.1 : Créer des routes personnalisées
# Objectif : Créer une route personnalisée pour tester l'export/import

set -e

echo "=== Lab 4.2 - Exercice 1 : Créer des routes personnalisées ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export ZONE="europe-west1-b"

echo "Création d'une route personnalisée dans VPC Alpha..."
echo ""

# Créer une route personnalisée dans VPC Alpha (vers un réseau fictif)
gcloud compute routes create custom-route-alpha \
    --network=$VPC_ALPHA \
    --destination-range=192.168.100.0/24 \
    --next-hop-instance=vm-alpha \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

echo ""
echo "Route personnalisée créée avec succès !"
echo ""

# Vérifier que la route existe dans VPC Alpha
echo "=== Routes dans VPC Alpha ==="
gcloud compute routes list --filter="network=$VPC_ALPHA"
echo ""

echo "Questions à considérer :"
echo "1. Cette route apparaît-elle automatiquement dans VPC Beta ?"
echo "2. Quel est le comportement par défaut pour l'export des routes personnalisées ?"
