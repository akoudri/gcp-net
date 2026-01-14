#!/bin/bash
# Lab 10.8 - Exercice 10.8.3 : Créer le backend service hybride
# Objectif : Créer un backend service avec le Hybrid NEG

set -e

echo "=== Lab 10.8 - Exercice 3 : Créer le backend service hybride ==="
echo ""

# Variables
export ZONE="europe-west1-b"

# Backend service avec le Hybrid NEG
echo "Création du backend service backend-hybrid..."
gcloud compute backend-services create backend-hybrid \
    --protocol=HTTP \
    --health-checks=hc-web \
    --global

echo ""
echo "Ajout du NEG hybride au backend..."

# Ajouter le NEG hybride
gcloud compute backend-services add-backend backend-hybrid \
    --network-endpoint-group=neg-onprem \
    --network-endpoint-group-zone=$ZONE \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100 \
    --global

echo ""
echo "Vérification de la configuration..."

# Vérifier
gcloud compute backend-services describe backend-hybrid \
    --global \
    --format="yaml(backends)"

echo ""
echo "Backend service hybride créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "Backend Service : backend-hybrid"
echo "NEG : neg-onprem"
echo "Balancing Mode : RATE"
echo "Max Rate per Endpoint : 100"
echo ""
echo "Ce backend peut maintenant être utilisé dans un URL Map"
echo "pour router du trafic vers des serveurs on-premise."
