#!/bin/bash
# Lab 10.4 - Exercice 10.4.2 : Configurer le Traffic Splitting (Canary)
# Objectif : Configurer le traffic splitting 90/10 entre v1 et v2

set -e

echo "=== Lab 10.4 - Exercice 2 : Configurer le Traffic Splitting ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

# Créer un URL Map avec traffic splitting
echo "Création de l'URL Map avec traffic splitting..."
cat > urlmap-canary.yaml << EOF
name: urlmap-canary
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
hostRules:
- hosts:
  - "*"
  pathMatcher: canary-matcher
pathMatchers:
- name: canary-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
  routeRules:
  - priority: 1
    matchRules:
    - prefixMatch: /
    routeAction:
      weightedBackendServices:
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
        weight: 90
      - backendService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v2
        weight: 10
EOF

echo ""
echo "Import de l'URL Map..."
gcloud compute url-maps import urlmap-canary \
    --source=urlmap-canary.yaml \
    --global

echo ""
echo "Mise à jour du proxy HTTP..."

# Mettre à jour le proxy pour utiliser le nouvel URL Map
gcloud compute target-http-proxies update proxy-http-app \
    --url-map=urlmap-canary

echo ""
echo "Traffic Splitting configuré avec succès !"
echo ""
echo "=== Résumé ==="
echo "Configuration Canary :"
echo "  - Version 1 (Stable) : 90% du trafic"
echo "  - Version 2 (Canary) : 10% du trafic"
echo ""
echo "Attendez quelques minutes que la configuration se propage."
