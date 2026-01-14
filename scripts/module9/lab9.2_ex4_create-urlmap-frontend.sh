#!/bin/bash
# Lab 9.2 - Exercice 9.2.4 : Créer l'URL Map et le Frontend
# Objectif : Créer l'URL map, réserver l'IP et configurer le frontend

set -e

echo "=== Lab 9.2 - Exercice 4 : Créer l'URL Map et le Frontend ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# URL Map
echo "Création de l'URL map..."
gcloud compute url-maps create urlmap-web \
    --default-service=backend-web

echo ""
echo "Réservation d'une IP externe..."
gcloud compute addresses create lb-ip \
    --ip-version=IPV4 \
    --global

# Récupérer l'IP
LB_IP=$(gcloud compute addresses describe lb-ip --global --format="get(address)")
echo "IP du Load Balancer: $LB_IP"

echo ""
echo "Création du target HTTP proxy..."
gcloud compute target-http-proxies create proxy-http \
    --url-map=urlmap-web

echo ""
echo "Création de la forwarding rule..."
gcloud compute forwarding-rules create fr-http \
    --address=lb-ip \
    --target-http-proxy=proxy-http \
    --ports=80 \
    --global

echo ""
echo "Load Balancer créé avec succès !"
echo ""
echo "=========================================="
echo "Load Balancer accessible sur: http://$LB_IP"
echo "=========================================="
echo ""

# Vérifier
echo "=== URL Map ==="
gcloud compute url-maps describe urlmap-web
echo ""

echo "=== Forwarding Rule ==="
gcloud compute forwarding-rules describe fr-http --global
echo ""

echo "IMPORTANT : Le Load Balancer peut prendre quelques minutes pour être complètement opérationnel."
echo "Attendez que les backends soient 'HEALTHY' avant de tester."
