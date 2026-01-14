#!/bin/bash
# Lab 3.4 - Exercice 3.4.2 : Explorer la configuration BGP
# Objectif : Comprendre la configuration BGP du Cloud Router

set -e

echo "=== Lab 3.4 - Exercice 2 : Explorer la configuration BGP ==="
echo ""

# Variables
export REGION_EU="europe-west1"

echo "Région : $REGION_EU"
echo ""

# Voir le statut BGP du router
echo "=== Statut BGP du router ==="
gcloud compute routers get-status my-cloud-router \
    --region=$REGION_EU
echo ""

# Voir les routes annoncées (vide sans VPN/Interconnect)
echo "=== Routes annoncées (bgpPeerStatus) ==="
gcloud compute routers get-status my-cloud-router \
    --region=$REGION_EU \
    --format="yaml(result.bgpPeerStatus)"
echo ""

echo "Note : Les routes BGP seront visibles uniquement avec un VPN ou Interconnect actif."
echo ""
