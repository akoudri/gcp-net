#!/bin/bash
# Lab 10.2 - Exercice 10.2.7 : Créer le Frontend (HTTP)
# Objectif : Créer le target proxy et la forwarding rule

set -e

echo "=== Lab 10.2 - Exercice 7 : Créer le Frontend HTTP ==="
echo ""

# Réserver une IP externe
echo "Réservation d'une IP externe globale..."
gcloud compute addresses create lb-ip-global \
    --ip-version=IPV4 \
    --global

echo ""
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer : $LB_IP"

echo ""
echo "Création du target HTTP proxy..."

# Target HTTP proxy
gcloud compute target-http-proxies create proxy-http-app \
    --url-map=urlmap-app

echo ""
echo "Création de la forwarding rule..."

# Forwarding rule HTTP
gcloud compute forwarding-rules create fr-http-app \
    --address=lb-ip-global \
    --target-http-proxy=proxy-http-app \
    --ports=80 \
    --global

echo ""
echo "Frontend HTTP créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "IP du Load Balancer : $LB_IP"
echo "Target proxy : proxy-http-app"
echo "Forwarding rule : fr-http-app"
echo ""
echo "Load Balancer accessible sur : http://$LB_IP"
echo ""
echo "Attendez 5-10 minutes que le Load Balancer soit complètement opérationnel."
