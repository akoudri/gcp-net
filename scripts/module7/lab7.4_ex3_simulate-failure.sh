#!/bin/bash
# Lab 7.4 - Exercice 7.4.3 : Simuler une panne de tunnel
# Objectif : Supprimer un tunnel pour simuler une panne

set -e

echo "=== Lab 7.4 - Exercice 3 : Simuler une panne de tunnel ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

echo "⚠️  ATTENTION : Ce script va supprimer temporairement un tunnel VPN."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Opération annulée."
    exit 0
fi

echo ""

# Option 1: Supprimer temporairement un tunnel
echo "=== Suppression du tunnel 0 pour simuler une panne ==="
gcloud compute vpn-tunnels delete tunnel-gcp-to-onprem-0 \
    --region=$REGION --quiet

echo ""
echo "Observer le ping dans l'autre terminal."
echo "Quelques paquets peuvent être perdus pendant la convergence BGP."

echo ""

# Vérifier le statut
echo "=== État des tunnels après la panne ==="
gcloud compute vpn-tunnels list --filter="region:$REGION"

echo ""
echo "=== Statut BGP après la panne ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="yaml(result.bgpPeerStatus)"

echo ""
echo "=== Simulation de panne terminée ==="
