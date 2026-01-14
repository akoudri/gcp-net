#!/bin/bash
# Lab 4.2 - Exercice 4.2.6 : Documenter la configuration du peering
# Objectif : Créer un script pour documenter tous les peerings du projet

set -e

echo "=== Lab 4.2 - Exercice 6 : Documenter la configuration du peering ==="
echo ""

echo "=== Documentation des VPC Peerings ==="
echo ""

for VPC in $(gcloud compute networks list --format="get(name)"); do
    echo "VPC: $VPC"
    echo "---"
    gcloud compute networks peerings list --network=$VPC \
        --format="table(name,peerNetwork,state,exportCustomRoutes,importCustomRoutes)" 2>/dev/null || echo "Aucun peering"
    echo ""
done

echo "Documentation terminée !"
