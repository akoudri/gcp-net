#!/bin/bash
# Lab 10.9 - Exercice 10.9.3 : Créer un Internet NEG
# Objectif : Créer un NEG pour un backend externe sur Internet

set -e

echo "=== Lab 10.9 - Exercice 3 : Créer un Internet NEG ==="
echo ""

# Internet NEG pour un backend externe
echo "Création de l'Internet NEG..."
gcloud compute network-endpoint-groups create neg-external \
    --network-endpoint-type=INTERNET_FQDN_PORT \
    --global

echo ""
echo "Ajout d'un endpoint externe (exemple : httpbin.org)..."

# Ajouter un endpoint externe (exemple: API publique)
gcloud compute network-endpoint-groups update neg-external \
    --add-endpoint="fqdn=httpbin.org,port=443" \
    --global

echo ""
echo "Création du backend service..."

# Backend service pour l'Internet NEG
gcloud compute backend-services create backend-external \
    --protocol=HTTPS \
    --global

echo ""
echo "Ajout du NEG au backend service..."

gcloud compute backend-services add-backend backend-external \
    --network-endpoint-group=neg-external \
    --global-network-endpoint-group \
    --global

echo ""
echo "Internet NEG créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "Internet NEG : neg-external"
echo "Type : INTERNET_FQDN_PORT"
echo "Endpoint : httpbin.org:443"
echo "Backend Service : backend-external"
echo ""
echo "Cas d'usage :"
echo "  - Proxy vers des APIs externes"
echo "  - Intégration de services tiers"
echo "  - Migration depuis un autre cloud provider"
echo ""
echo "Pour utiliser ce backend, ajoutez-le à un URL Map."
