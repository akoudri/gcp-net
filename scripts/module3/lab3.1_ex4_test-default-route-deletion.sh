#!/bin/bash
# Lab 3.1 - Exercice 3.1.4 : Tester la suppression de la route par défaut
# Objectif : Comprendre l'importance de la route par défaut

set -e

echo "=== Lab 3.1 - Exercice 4 : Tester la suppression de la route par défaut ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

# Obtenir le nom exact de la route par défaut
echo "Recherche de la route par défaut..."
DEFAULT_ROUTE=$(gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=0.0.0.0/0" \
    --format="get(name)")

echo "Route par défaut : $DEFAULT_ROUTE"
echo ""

# Supprimer la route par défaut
echo "Suppression de la route par défaut..."
gcloud compute routes delete $DEFAULT_ROUTE --quiet

echo ""
echo "Route par défaut supprimée."
echo ""

# Vérifier qu'elle a disparu
echo "=== Routes restantes ==="
gcloud compute routes list --filter="network=$VPC_NAME"
echo ""

# Recréer la route par défaut manuellement
echo "Recréation de la route par défaut manuellement..."
gcloud compute routes create default-internet-route \
    --network=$VPC_NAME \
    --destination-range=0.0.0.0/0 \
    --next-hop-gateway=default-internet-gateway \
    --priority=1000

echo ""
echo "Route par défaut recréée."
echo ""

# Vérifier
echo "=== Routes après recréation ==="
gcloud compute routes list --filter="network=$VPC_NAME"
echo ""

echo "Questions à considérer :"
echo "1. Après suppression de la route par défaut, les VMs peuvent-elles accéder à Internet ?"
echo "2. La route par défaut peut-elle être recréée avec une priorité différente ?"
echo ""
