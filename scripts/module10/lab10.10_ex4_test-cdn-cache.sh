#!/bin/bash
# Lab 10.10 - Exercice 10.10.4 : Tester le cache CDN
# Objectif : Tester et observer les headers de cache CDN

set -e

echo "=== Lab 10.10 - Exercice 4 : Tester le cache CDN ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer : $LB_IP"
echo ""

# Tester et observer les headers de cache
echo "=== Première requête (cache MISS attendu) ==="
curl -sI http://$LB_IP/static/style.css | grep -E "(X-Cache|Age|Cache-Control|HTTP)"

echo ""
echo "Attendez 3 secondes..."
sleep 3

echo ""
echo "=== Deuxième requête (cache HIT attendu) ==="
curl -sI http://$LB_IP/static/style.css | grep -E "(X-Cache|Age|Cache-Control|HTTP)"

echo ""
echo "Attendez 3 secondes..."
sleep 3

echo ""
echo "=== Troisième requête (cache HIT, Age devrait augmenter) ==="
curl -sI http://$LB_IP/static/style.css | grep -E "(X-Cache|Age|Cache-Control|HTTP)"

echo ""
echo ""
echo "=== Headers importants ==="
echo "X-Cache : HIT/MISS indique si servi du cache"
echo "Age : Temps (en secondes) depuis la mise en cache"
echo "Cache-Control : Politique de cache"
echo ""
echo "Note : Il peut falloir plusieurs requêtes avant d'obtenir un HIT"
echo "       car le cache est distribué globalement."
