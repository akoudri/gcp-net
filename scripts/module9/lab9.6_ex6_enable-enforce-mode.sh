#!/bin/bash
# Lab 9.6 - Exercice 9.6.6 : Activer les règles en mode Enforce
# Objectif : Passer les règles WAF en mode Enforce (blocage effectif)

set -e

echo "=== Lab 9.6 - Exercice 6 : Activer les règles en mode Enforce ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")

# Passer en mode Enforce
echo "Activation de la règle SQLi en mode Enforce..."
gcloud compute security-policies rules update 1000 \
    --security-policy=policy-web-app \
    --no-preview

echo ""
echo "Activation de la règle XSS en mode Enforce..."
gcloud compute security-policies rules update 1100 \
    --security-policy=policy-web-app \
    --no-preview

echo ""
echo "Règles WAF activées en mode Enforce !"
echo ""

# Attendre un peu
echo "Attente de l'application des règles (10 secondes)..."
sleep 10

# Tester à nouveau
echo "=== Test de blocage effectif ==="
echo "Test SQL Injection: ?id=1 OR 1=1"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$LB_IP/?id=1%20OR%201=1")
echo "Code HTTP: $HTTP_CODE"

echo ""
if [ "$HTTP_CODE" == "403" ]; then
    echo "✓ Les règles WAF bloquent maintenant les attaques !"
else
    echo "⚠ Code HTTP: $HTTP_CODE (attendu: 403)"
    echo "Les règles peuvent prendre quelques secondes à s'appliquer en mode Enforce."
fi

echo ""
echo "REMARQUE : Les requêtes malveillantes sont maintenant bloquées avec HTTP 403."
