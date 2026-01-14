#!/bin/bash
# Lab 10.4 - Exercice 10.4.5 : Déploiement Blue-Green
# Objectif : Basculer instantanément entre deux versions

set -e

echo "=== Lab 10.4 - Exercice 5 : Déploiement Blue-Green ==="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")

echo "Principe du Blue-Green :"
echo "  - Blue (actuel) : backend-v1"
echo "  - Green (nouveau) : backend-v2"
echo "  - Le switch est instantané"
echo ""

echo "État actuel du Load Balancer :"
gcloud compute url-maps describe urlmap-canary --global --format="get(defaultService)"
echo ""

read -p "Voulez-vous basculer vers Green (backend-v2) ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Basculement vers Green (v2)..."

    # Switch vers Green (v2)
    gcloud compute url-maps set-default-service urlmap-canary \
        --default-service=backend-v2 \
        --global

    echo ""
    echo "Trafic redirigé vers backend-v2 (Green)"
    echo ""

    # Vérifier
    echo "Vérification..."
    sleep 10
    curl -s http://$LB_IP/ | grep "Version"

    echo ""
    echo ""
    read -p "Voulez-vous effectuer un rollback vers Blue (backend-v1) ? (y/N) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Rollback vers Blue (v1)..."

        # Rollback vers Blue (v1)
        gcloud compute url-maps set-default-service urlmap-canary \
            --default-service=backend-v1 \
            --global

        echo ""
        echo "Rollback vers backend-v1 (Blue)"
        echo ""

        # Vérifier
        echo "Vérification..."
        sleep 10
        curl -s http://$LB_IP/ | grep "Version"
    fi
fi

echo ""
echo ""
echo "Déploiement Blue-Green terminé !"
echo ""
echo "Avantages du Blue-Green :"
echo "  - Switch instantané"
echo "  - Rollback rapide"
echo "  - Aucun downtime"
