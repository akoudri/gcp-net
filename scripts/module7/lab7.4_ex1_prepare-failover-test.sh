#!/bin/bash
# Lab 7.4 - Exercice 7.4.1 : Préparer le test de failover
# Objectif : Vérifier l'état initial avant le test de failover

set -e

echo "=== Lab 7.4 - Exercice 1 : Préparer le test de failover ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Vérifier que les deux tunnels sont actifs
echo "=== État initial des tunnels ==="
gcloud compute vpn-tunnels list --filter="region:$REGION" \
    --format="table(name,status)"

echo ""

# Vérifier les sessions BGP
echo "=== Sessions BGP actives ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="table(result.bgpPeerStatus[].name,result.bgpPeerStatus[].status)"

echo ""
echo "=== Préparation terminée ==="
echo ""
echo "Tous les tunnels devraient être dans l'état 'Established'."
