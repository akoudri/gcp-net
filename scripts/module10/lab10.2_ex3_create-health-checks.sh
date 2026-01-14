#!/bin/bash
# Lab 10.2 - Exercice 10.2.3 : Créer les Health Checks
# Objectif : Créer les health checks pour le web et l'API

set -e

echo "=== Lab 10.2 - Exercice 3 : Créer les Health Checks ==="
echo ""

# Health check pour le web
echo "Création du health check pour le web..."
gcloud compute health-checks create http hc-web \
    --port=80 \
    --request-path="/health/" \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

echo ""
echo "Création du health check pour l'API..."

# Health check pour l'API
gcloud compute health-checks create http hc-api \
    --port=80 \
    --request-path="/health/" \
    --check-interval=10s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=3

echo ""
echo "Health checks créés avec succès !"
echo ""
echo "=== Résumé ==="
echo "Health Checks :"
echo "  - hc-web : HTTP port 80, path /health/"
echo "  - hc-api : HTTP port 80, path /health/"
echo ""
echo "Configuration :"
echo "  - Intervalle : 10s"
echo "  - Timeout : 5s"
echo "  - Healthy threshold : 2"
echo "  - Unhealthy threshold : 3"
