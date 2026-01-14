#!/bin/bash
# Lab 10.4 - Exercice 10.4.3 : Tester le Traffic Splitting
# Objectif : Tester la distribution du trafic entre v1 et v2

set -e

echo "=== Lab 10.4 - Exercice 3 : Tester le Traffic Splitting ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer : $LB_IP"
echo ""

# Tester la distribution (environ 90% v1, 10% v2)
echo "Test de distribution du trafic (20 requêtes)..."
echo ""

V1_COUNT=0
V2_COUNT=0

for i in {1..20}; do
    RESPONSE=$(curl -s http://$LB_IP/ | grep -o "Version [12]")
    if [[ "$RESPONSE" == "Version 1" ]]; then
        ((V1_COUNT++))
        echo "Requête $i : Version 1"
    else
        ((V2_COUNT++))
        echo "Requête $i : Version 2"
    fi
done

echo ""
echo "=== Résultats ==="
echo "Version 1 (stable) : $V1_COUNT requêtes ($(($V1_COUNT * 5))%)"
echo "Version 2 (canary) : $V2_COUNT requêtes ($(($V2_COUNT * 5))%)"
echo ""
echo "Attendu : ~90% v1, ~10% v2"
echo ""
echo "Note : La distribution peut varier légèrement en raison du faible nombre de requêtes."
