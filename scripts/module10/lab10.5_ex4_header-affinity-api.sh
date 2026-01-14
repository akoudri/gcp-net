#!/bin/bash
# Lab 10.5 - Exercice 10.5.4 : Affinité par header (API)
# Objectif : Configurer l'affinité basée sur un header pour les APIs

set -e

echo "=== Lab 10.5 - Exercice 4 : Affinité par header (API) ==="
echo ""

# Configurer l'affinité par header Authorization
echo "Configuration de l'affinité par header sur backend-api..."
gcloud compute backend-services update backend-api \
    --session-affinity=HEADER_FIELD \
    --custom-request-header="X-Session-Token:{client_ip}" \
    --global

echo ""
echo "Vérification de la configuration..."
gcloud compute backend-services describe backend-api \
    --global \
    --format="yaml(sessionAffinity,customRequestHeaders)"

echo ""
echo "Configuration terminée !"
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")

# Tester avec différents tokens
echo "=== Tests avec différents tokens ==="
echo ""

echo "Test avec Token A :"
curl -H "Authorization: Bearer tokenA" -s http://$LB_IP/api/ | head -1

echo ""
echo "Test avec Token B :"
curl -H "Authorization: Bearer tokenB" -s http://$LB_IP/api/ | head -1

echo ""
echo "Test avec Token A (devrait retourner le même backend) :"
curl -H "Authorization: Bearer tokenA" -s http://$LB_IP/api/ | head -1

echo ""
echo ""
echo "=== Résumé ==="
echo "Backend Service : backend-api"
echo "Session Affinity : HEADER_FIELD"
echo ""
echo "Les requêtes avec le même token devraient aller au même backend."
