#!/bin/bash
# Lab 10.2 - Exercice 10.2.4 : Créer les Backend Services
# Objectif : Créer les backend services et y attacher les instance groups

set -e

echo "=== Lab 10.2 - Exercice 4 : Créer les Backend Services ==="
echo ""

# Variables
export ZONE="europe-west1-b"

# Backend service pour le web
echo "Création du backend service backend-web..."
gcloud compute backend-services create backend-web \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-web \
    --global 2>/dev/null || echo "Backend service backend-web existe déjà"

echo ""
echo "Ajout de ig-web au backend-web..."
gcloud compute backend-services add-backend backend-web \
    --instance-group=ig-web \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global 2>&1 | grep -v "already contains" || true

echo ""
echo "Création du backend service backend-api..."

# Backend service pour l'API
gcloud compute backend-services create backend-api \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-api \
    --global 2>/dev/null || echo "Backend service backend-api existe déjà"

echo ""
echo "Ajout de ig-api au backend-api..."
gcloud compute backend-services add-backend backend-api \
    --instance-group=ig-api \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global 2>&1 | grep -v "already contains" || true

echo ""
echo "Backend Services créés avec succès !"
echo ""
echo "=== Résumé ==="
echo "Backend Services :"
echo "  - backend-web : lié à ig-web"
echo "  - backend-api : lié à ig-api"
echo ""
echo "Configuration :"
echo "  - Mode : UTILIZATION"
echo "  - Max utilization : 80%"
