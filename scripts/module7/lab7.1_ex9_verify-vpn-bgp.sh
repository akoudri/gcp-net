#!/bin/bash
# Lab 7.1 - Exercice 7.1.9 : Vérifier l'état des tunnels et sessions BGP
# Objectif : Vérifier que les tunnels VPN et les sessions BGP sont établis

set -e

echo "=== Lab 7.1 - Exercice 9 : Vérifier l'état des tunnels et sessions BGP ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Attendre quelques secondes pour l'établissement
echo ">>> Attente de l'établissement des tunnels et sessions BGP (30 secondes)..."
sleep 30

echo ""

# État des tunnels VPN
echo "=== État des tunnels VPN ==="
gcloud compute vpn-tunnels list --filter="region:$REGION" \
    --format="table(name,status,peerIp)"

echo ""

# Statut BGP côté GCP
echo "=== Statut BGP Router GCP ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="yaml(result.bgpPeerStatus)"

echo ""

# Statut BGP côté On-premise
echo "=== Statut BGP Router On-premise ==="
gcloud compute routers get-status router-onprem --region=$REGION \
    --format="yaml(result.bgpPeerStatus)"

echo ""

# Routes apprises
echo "=== Routes apprises par router-gcp ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="yaml(result.bestRoutes)"

echo ""
echo "=== Vérification terminée ==="
echo "Les tunnels devraient être dans l'état 'Established' et les sessions BGP actives."
