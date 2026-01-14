#!/bin/bash
# Lab 9.3 - Exercice 9.3.5 : Tester que la politique est active
# Objectif : Vérifier que la politique Cloud Armor est active

set -e

echo "=== Lab 9.3 - Exercice 5 : Tester que la politique est active ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"
echo ""

# Tester l'accès
echo "Test de l'accès au Load Balancer..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP)

echo "Code HTTP retourné : $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" == "200" ]; then
    echo "✓ La politique est attachée et autorise le trafic (comportement par défaut)"
else
    echo "✗ Code HTTP inattendu : $HTTP_CODE"
fi

echo ""
echo "REMARQUE : La politique est attachée mais autorise tout (règle par défaut)."
echo "Les logs Cloud Armor sont générés même sans blocage."
echo ""
echo "Pour voir les logs dans Cloud Console :"
echo "Network Security > Cloud Armor > Logs"
