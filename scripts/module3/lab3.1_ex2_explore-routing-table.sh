#!/bin/bash
# Lab 3.1 - Exercice 3.1.2 : Explorer la table de routage
# Objectif : Comprendre les routes créées automatiquement

set -e

echo "=== Lab 3.1 - Exercice 2 : Explorer la table de routage ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Lister toutes les routes du VPC
echo "=== Routes du VPC ==="
gcloud compute routes list --filter="network=$VPC_NAME"
echo ""

# Afficher les détails de chaque route
echo "=== Détails des routes (format table) ==="
gcloud compute routes list \
    --filter="network=$VPC_NAME" \
    --format="table(name,destRange,nextHopGateway,nextHopNetwork,priority)"
echo ""

echo "Questions à considérer :"
echo "1. Combien de routes ont été créées automatiquement ?"
echo "2. Identifiez la route par défaut vers Internet. Quel est son next-hop ?"
echo "3. Identifiez les routes de sous-réseau. Quelle est leur destination ?"
echo ""
