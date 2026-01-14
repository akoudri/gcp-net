#!/bin/bash
# Lab 9.5 - Exercice 9.5.3 : Filtrage par méthode HTTP
# Objectif : Bloquer les méthodes DELETE et PUT sur /api

set -e

echo "=== Lab 9.5 - Exercice 3 : Filtrage par méthode HTTP ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")

# Bloquer les méthodes DELETE et PUT sur /api
echo "Création d'une règle pour bloquer DELETE/PUT sur /api..."
gcloud compute security-policies rules create 310 \
    --security-policy=policy-web-app \
    --expression="(request.method == 'DELETE' || request.method == 'PUT') && request.path.startsWith('/api')" \
    --action=deny-403 \
    --description="Bloquer DELETE/PUT sur /api"

echo ""
echo "Règle créée avec succès !"
echo ""

# Attendre un peu
echo "Attente de l'application de la règle (10 secondes)..."
sleep 10

# Tester
echo "=== Tests ==="
echo "Test 1 : DELETE sur /api/test (devrait retourner 403)"
HTTP_CODE_DELETE=$(curl -X DELETE -s -o /dev/null -w "%{http_code}" http://$LB_IP/api/test)
echo "Code HTTP pour DELETE /api/test : $HTTP_CODE_DELETE"

echo ""
echo "Test 2 : GET sur /api/test (devrait retourner 200 ou 404, mais pas 403)"
HTTP_CODE_GET=$(curl -X GET -s -o /dev/null -w "%{http_code}" http://$LB_IP/api/test)
echo "Code HTTP pour GET /api/test : $HTTP_CODE_GET"

echo ""
if [ "$HTTP_CODE_DELETE" == "403" ] && [ "$HTTP_CODE_GET" != "403" ]; then
    echo "✓ La règle fonctionne correctement !"
else
    echo "⚠ Résultats inattendus. La règle peut prendre quelques secondes à s'appliquer."
fi
