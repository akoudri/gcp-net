#!/bin/bash
# Lab 9.5 - Exercice 9.5.6 : Filtrage par query string
# Objectif : Bloquer les requêtes avec des paramètres suspects

set -e

echo "=== Lab 9.5 - Exercice 6 : Filtrage par query string ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")

# Bloquer les requêtes avec des paramètres suspects
echo "Création d'une règle pour bloquer les query strings suspectes..."
gcloud compute security-policies rules create 340 \
    --security-policy=policy-web-app \
    --expression="request.query.matches('.*(<script>|SELECT|UNION|DROP).*')" \
    --action=deny-403 \
    --description="Bloquer query strings suspectes"

echo ""
echo "Règle créée avec succès !"
echo ""

# Attendre un peu
echo "Attente de l'application de la règle (10 secondes)..."
sleep 10

# Tester
echo "=== Tests ==="
echo "Test avec query string suspecte..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$LB_IP/?search=SELECT%20*%20FROM%20users")
echo "Code HTTP : $HTTP_CODE"

echo ""
if [ "$HTTP_CODE" == "403" ]; then
    echo "✓ La règle fonctionne correctement !"
else
    echo "⚠ Code HTTP : $HTTP_CODE (attendu : 403)"
    echo "La règle peut prendre quelques secondes à s'appliquer."
fi

echo ""
echo "REMARQUE : Cette règle bloque les query strings contenant des patterns d'injection SQL."
