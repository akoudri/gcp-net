#!/bin/bash
# Lab 9.7 - Exercice 9.7.6 : Rate limiting par header (API)
# Objectif : Limiter par clé API (header x-api-key)

set -e

echo "=== Lab 9.7 - Exercice 6 : Rate limiting par header (API) ==="
echo ""

# Limiter par clé API (header x-api-key)
echo "Création d'une règle pour limiter par API key..."
gcloud compute security-policies rules create 530 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/api')" \
    --action=throttle \
    --rate-limit-threshold-count=1000 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=http-header \
    --enforce-on-key-name=x-api-key \
    --description="API: max 1000 req/min par API key"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 530 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle limite par valeur du header x-api-key."
echo "Chaque API key a son propre quota de 1000 req/min."
