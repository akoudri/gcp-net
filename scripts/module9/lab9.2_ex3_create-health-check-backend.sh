#!/bin/bash
# Lab 9.2 - Exercice 9.2.3 : Créer le Health Check et le Backend Service
# Objectif : Configurer le health check et le backend service

set -e

echo "=== Lab 9.2 - Exercice 3 : Créer le Health Check et le Backend Service ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo ""

# Health check HTTP
echo "Création du health check HTTP..."
gcloud compute health-checks create http hc-http-80 \
    --port=80 \
    --request-path="/health/" \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3 2>/dev/null || echo "Health check hc-http-80 existe déjà"

echo ""
echo "Création du backend service..."
gcloud compute backend-services create backend-web \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-http-80 \
    --global 2>/dev/null || echo "Backend service backend-web existe déjà"

echo ""
echo "Ajout du groupe d'instances au backend..."
gcloud compute backend-services add-backend backend-web \
    --instance-group=web-ig \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8 \
    --global

echo ""
echo "Health check et backend service créés avec succès !"
echo ""

# Vérifier
echo "=== Health Check ==="
gcloud compute health-checks describe hc-http-80
echo ""

echo "=== Backend Service ==="
gcloud compute backend-services describe backend-web --global
echo ""

echo "Vous pouvez vérifier l'état de santé des backends avec :"
echo "gcloud compute backend-services get-health backend-web --global"
