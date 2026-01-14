#!/bin/bash
# Lab 9.5 - Exercice 9.5.2 : Filtrage par chemin (path)
# Objectif : Bloquer l'accès à /admin

set -e

echo "=== Lab 9.5 - Exercice 2 : Filtrage par chemin ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")

# Bloquer /admin
echo "Création d'une règle pour bloquer /admin..."
gcloud compute security-policies rules create 300 \
    --security-policy=policy-web-app \
    --expression="request.path.startsWith('/admin')" \
    --action=deny-403 \
    --description="Bloquer /admin"

echo ""
echo "Règle créée avec succès !"
echo ""

# Attendre un peu
echo "Attente de l'application de la règle (10 secondes)..."
sleep 10

# Tester
echo "=== Tests ==="
echo "Test 1 : Accès à /admin (devrait retourner 403)"
HTTP_CODE_ADMIN=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP/admin)
echo "Code HTTP pour /admin : $HTTP_CODE_ADMIN"

echo ""
echo "Test 2 : Accès à / (devrait retourner 200)"
HTTP_CODE_ROOT=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP/)
echo "Code HTTP pour / : $HTTP_CODE_ROOT"

echo ""
if [ "$HTTP_CODE_ADMIN" == "403" ] && [ "$HTTP_CODE_ROOT" == "200" ]; then
    echo "✓ La règle fonctionne correctement !"
else
    echo "⚠ Résultats inattendus. La règle peut prendre quelques secondes à s'appliquer."
fi
