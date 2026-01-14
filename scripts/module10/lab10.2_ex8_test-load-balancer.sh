#!/bin/bash
# Lab 10.2 - Exercice 10.2.8 : Tester le Load Balancer
# Objectif : Tester les différentes routes du Load Balancer

set -e

echo "=== Lab 10.2 - Exercice 8 : Tester le Load Balancer ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer : $LB_IP"
echo ""

# Attendre que les backends soient healthy
echo "Attente des backends (60s)..."
sleep 60

echo ""
echo "Vérification de la santé des backends..."

# Vérifier la santé des backends
echo ""
echo "=== Backend Web ==="
gcloud compute backend-services get-health backend-web --global

echo ""
echo "=== Backend API ==="
gcloud compute backend-services get-health backend-api --global

echo ""
echo "Tests des différentes routes..."

# Tester les différentes routes
echo ""
echo "=== Test Frontend ==="
curl -s http://$LB_IP/

echo ""
echo ""
echo "=== Test API ==="
curl -s http://$LB_IP/api/

echo ""
echo ""
echo "=== Test Static ==="
curl -s http://$LB_IP/static/style.css

echo ""
echo ""
echo "Tests terminés !"
echo ""
echo "Pour tester dans un navigateur, ouvrez : http://$LB_IP"
