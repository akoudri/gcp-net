#!/bin/bash
# Lab 10.8 - Exercice 10.8.4 : Configurer le failover GCP ↔ On-premise
# Objectif : Créer un URL Map avec traffic splitting entre GCP et on-premise

set -e

echo "=== Lab 10.8 - Exercice 4 : Configurer le failover hybride ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

# URL Map avec failover
echo "Création de l'URL Map avec traffic splitting GCP/On-premise..."
cat > urlmap-hybrid.yaml << EOF
name: urlmap-hybrid
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-web
hostRules:
- hosts:
  - "*"
  pathMatcher: hybrid-matcher
pathMatchers:
- name: hybrid-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-web
  routeRules:
  # Traffic splitting entre GCP et on-premise
  - priority: 1
    matchRules:
    - prefixMatch: /
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-web
        weight: 80
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-hybrid
        weight: 20
EOF

echo ""
echo "Import de l'URL Map..."
gcloud compute url-maps import urlmap-hybrid \
    --source=urlmap-hybrid.yaml \
    --global

echo ""
echo "Configuration hybride créée avec succès !"
echo ""
echo "=== Résumé ==="
echo "URL Map : urlmap-hybrid"
echo "Traffic Splitting :"
echo "  - 80% → backend-web (GCP)"
echo "  - 20% → backend-hybrid (On-premise)"
echo ""
echo "Cas d'usage :"
echo "  - Migration progressive vers le cloud"
echo "  - Disaster recovery"
echo "  - Hybrid cloud architecture"
echo ""
echo "Pour activer :"
echo "  gcloud compute target-http-proxies update proxy-http-app --url-map=urlmap-hybrid"
