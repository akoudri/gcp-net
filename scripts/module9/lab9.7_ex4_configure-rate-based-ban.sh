#!/bin/bash
# Lab 9.7 - Exercice 9.7.4 : Configurer le Rate-Based Ban
# Objectif : Bannir pendant 5 minutes si plus de 100 req/min

set -e

echo "=== Lab 9.7 - Exercice 4 : Configurer le Rate-Based Ban ==="
echo ""

# Si plus de 100 req/min, bannir pendant 5 minutes
echo "Création d'une règle de rate-based ban..."
gcloud compute security-policies rules create 510 \
    --security-policy=policy-web-app \
    --src-ip-ranges="0.0.0.0/0" \
    --action=rate-based-ban \
    --rate-limit-threshold-count=100 \
    --rate-limit-threshold-interval-sec=60 \
    --ban-duration-sec=300 \
    --conform-action=allow \
    --exceed-action=deny-403 \
    --enforce-on-key=IP \
    --description="Ban 5min si >100 req/min"

echo ""
echo "Règle créée avec succès !"
echo ""

# Vérifier
echo "=== Détails de la règle ==="
gcloud compute security-policies rules describe 510 \
    --security-policy=policy-web-app

echo ""
echo "REMARQUE : Si une IP dépasse 100 req/min, elle sera bannie pendant 5 minutes."
echo "Pendant le ban, TOUTES les requêtes de cette IP sont bloquées (HTTP 403)."
