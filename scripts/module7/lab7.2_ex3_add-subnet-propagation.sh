#!/bin/bash
# Lab 7.2 - Exercice 7.2.3 : Ajouter un sous-réseau et observer la propagation
# Objectif : Observer la propagation automatique des nouvelles routes via BGP

set -e

echo "=== Lab 7.2 - Exercice 3 : Ajouter un sous-réseau et observer la propagation ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Ajouter un nouveau sous-réseau dans vpc-gcp
echo ">>> Ajout d'un nouveau sous-réseau dans vpc-gcp..."
gcloud compute networks subnets create subnet-gcp-new \
    --network=vpc-gcp \
    --region=$REGION \
    --range=10.1.0.0/24

echo ""
echo ">>> Attente de la propagation BGP (30 secondes)..."
sleep 30

echo ""

# Vérifier que le nouveau sous-réseau est annoncé
echo "=== Routes apprises par router-onprem après ajout ==="
gcloud compute routers get-status router-onprem --region=$REGION \
    --format="yaml(result.bestRoutes)"

echo ""
echo "=== Propagation terminée ==="
echo "Le sous-réseau 10.1.0.0/24 devrait maintenant apparaître dans les routes apprises."
