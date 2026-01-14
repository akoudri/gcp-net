#!/bin/bash
# Lab 3.2 - Exercice 3.2.7 : Nettoyer les routes de test
# Objectif : Supprimer les routes personnalisées de test

set -e

echo "=== Lab 3.2 - Exercice 7 : Nettoyer les routes de test ==="
echo ""

# Supprimer les routes personnalisées
echo "Suppression des routes de test..."
gcloud compute routes delete route-specific route-broad route-specific-backup --quiet

echo ""
echo "Routes de test supprimées avec succès !"
echo ""

export VPC_NAME="routing-lab-vpc"

echo "=== Routes restantes ==="
gcloud compute routes list --filter="network=$VPC_NAME"
echo ""
