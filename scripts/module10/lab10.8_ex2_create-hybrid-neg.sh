#!/bin/bash
# Lab 10.8 - Exercice 10.8.2 : Créer un Hybrid NEG (simulation)
# Objectif : Créer un Network Endpoint Group hybride pour des backends on-premise

set -e

echo "=== Lab 10.8 - Exercice 2 : Créer un Hybrid NEG ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Note : Ceci simule des backends on-premise"
echo "En production, les IPs seraient celles de vos serveurs on-premise"
echo ""

# Créer le Hybrid NEG
echo "Création du Hybrid NEG..."
gcloud compute network-endpoint-groups create neg-onprem \
    --network-endpoint-type=NON_GCP_PRIVATE_IP_PORT \
    --zone=$ZONE \
    --network=vpc-lb-lab

echo ""
echo "Ajout des endpoints (IPs simulées on-premise)..."

# Ajouter des endpoints (IPs simulées on-premise)
# En production: IPs de vos serveurs on-premise accessibles via VPN
gcloud compute network-endpoint-groups update neg-onprem \
    --zone=$ZONE \
    --add-endpoint="ip=10.1.1.10,port=80" \
    --add-endpoint="ip=10.1.1.11,port=80"

echo ""
echo "Liste des endpoints..."

# Lister les endpoints
gcloud compute network-endpoint-groups list-network-endpoints neg-onprem \
    --zone=$ZONE

echo ""
echo "Hybrid NEG créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "NEG : neg-onprem"
echo "Type : NON_GCP_PRIVATE_IP_PORT"
echo "Endpoints :"
echo "  - 10.1.1.10:80"
echo "  - 10.1.1.11:80"
echo ""
echo "Prérequis pour la production :"
echo "  - Connectivité réseau (VPN ou Interconnect)"
echo "  - IPs routables depuis GCP"
echo "  - Health checks accessibles"
