#!/bin/bash
# Lab 9.7 - Exercice 9.7.3 : Tester le Throttling
# Objectif : Envoyer 65 requêtes rapides pour déclencher le throttling

set -e

echo "=== Lab 9.7 - Exercice 3 : Tester le Throttling ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"
echo ""

# Script de test avec curl en boucle
echo "Test du throttling (65 requêtes rapides)..."
echo ""

SUCCESS=0
THROTTLED=0

for i in {1..65}; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_IP/)
    if [ "$CODE" == "200" ]; then
        ((SUCCESS++))
    elif [ "$CODE" == "429" ]; then
        ((THROTTLED++))
        if [ $THROTTLED -eq 1 ]; then
            echo "Première requête throttled à la requête #$i"
        fi
    fi

    # Affichage du progrès
    if [ $((i % 10)) -eq 0 ]; then
        echo "Requêtes envoyées: $i/65 (Succès: $SUCCESS, Throttled: $THROTTLED)"
    fi
done

echo ""
echo "=== Résultats ==="
echo "Succès (200): $SUCCESS"
echo "Throttled (429): $THROTTLED"
echo ""

if [ $THROTTLED -gt 0 ]; then
    echo "✓ Le throttling fonctionne correctement !"
else
    echo "⚠ Aucune requête throttled. Possible raisons:"
    echo "  - La règle n'est pas encore active (attendez quelques secondes)"
    echo "  - Le seuil de 60 req/min n'a pas été atteint assez rapidement"
fi
