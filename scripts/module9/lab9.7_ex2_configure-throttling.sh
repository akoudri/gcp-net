#!/bin/bash
# Lab 9.7 - Exercice 9.7.2 : Configurer le Throttling
# Objectif : Limiter à 60 requêtes par minute par IP

set -e

echo "=== Lab 9.7 - Exercice 2 : Configurer le Throttling ==="
echo ""

# Limiter à 60 requêtes par minute par IP
echo "Création d'une règle de throttling (60 req/min par IP)..."
gcloud compute security-policies rules create 500 \
    --security-policy=policy-web-app \
    --src-ip-ranges="0.0.0.0/0" \
    --action=throttle \
    --rate-limit-threshold-count=60 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --description="Throttle: max 60 req/min par IP"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 500 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle limite à 60 requêtes par minute par IP."
echo "Les requêtes excédentaires reçoivent un code HTTP 429 (Too Many Requests)."
