#!/bin/bash
# Lab 9.7 - Exercice 9.7.5 : Rate limiting par endpoint
# Objectif : Limiter spécifiquement le endpoint /api/login

set -e

echo "=== Lab 9.7 - Exercice 5 : Rate limiting par endpoint ==="
echo ""

# Limiter spécifiquement le endpoint /api/login
echo "Création d'une règle pour limiter /api/login..."
gcloud compute security-policies rules create 520 \
    --security-policy=policy-web-app \
    --expression="request.path == '/api/login'" \
    --action=throttle \
    --rate-limit-threshold-count=5 \
    --rate-limit-threshold-interval-sec=60 \
    --conform-action=allow \
    --exceed-action=deny-429 \
    --enforce-on-key=IP \
    --description="Login: max 5 tentatives/min par IP"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 520 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Cette règle limite spécifiquement /api/login à 5 tentatives par minute."
echo "C'est utile pour protéger contre les attaques de type brute-force sur le login."
