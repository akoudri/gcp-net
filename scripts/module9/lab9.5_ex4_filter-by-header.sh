#!/bin/bash
# Lab 9.5 - Exercice 9.5.4 : Filtrage par header
# Objectif : Bloquer les requêtes sans User-Agent valide et exiger API key

set -e

echo "=== Lab 9.5 - Exercice 4 : Filtrage par header ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")

# Bloquer les requêtes sans User-Agent valide
echo "Création d'une règle pour bloquer User-Agents invalides..."
gcloud compute security-policies rules create 320 \
    --security-policy=policy-web-app \
    --expression="!request.headers['user-agent'].matches('Mozilla.*|Chrome.*|Safari.*|curl.*')" \
    --action=deny-403 \
    --description="Bloquer User-Agents invalides"

echo ""
# Exiger un header API key pour /api
echo "Création d'une règle pour exiger un header x-api-key pour /api..."
gcloud compute security-policies rules create 330 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/api') && !request.headers['x-api-key'].matches('.+')" \
    --action=deny-403 \
    --description="API key requise pour /api"

echo ""
echo "Règles créées avec succès !"
echo ""

# Attendre un peu
echo "Attente de l'application des règles (10 secondes)..."
sleep 10

# Tester
echo "=== Tests ==="
echo "Test 1 : Requête /api/test sans header x-api-key (devrait retourner 403)"
HTTP_CODE_NO_KEY=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP/api/test)
echo "Code HTTP sans header : $HTTP_CODE_NO_KEY"

echo ""
echo "Test 2 : Requête /api/test avec header x-api-key (devrait retourner 200 ou 404)"
HTTP_CODE_WITH_KEY=$(curl -H "x-api-key: test123" -s -o /dev/null -w "%{http_code}" http://$LB_IP/api/test)
echo "Code HTTP avec header : $HTTP_CODE_WITH_KEY"

echo ""
if [ "$HTTP_CODE_NO_KEY" == "403" ] && [ "$HTTP_CODE_WITH_KEY" != "403" ]; then
    echo "✓ La règle fonctionne correctement !"
else
    echo "⚠ Résultats inattendus. Les règles peuvent prendre quelques secondes à s'appliquer."
fi
