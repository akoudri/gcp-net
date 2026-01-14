#!/bin/bash
# Lab 10.4 - Exercice 10.4.6 : Routage basé sur les Headers
# Objectif : Router les utilisateurs beta vers la v2 en fonction d'un header

set -e

echo "=== Lab 10.4 - Exercice 6 : Routage basé sur les Headers ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

# Configurer le routage par header pour les beta testers
echo "Création de l'URL Map avec routage par header..."
cat > urlmap-header-routing.yaml << EOF
name: urlmap-header-routing
defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
hostRules:
- hosts:
  - "*"
  pathMatcher: header-matcher
pathMatchers:
- name: header-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
  routeRules:
  # Les utilisateurs beta (header X-Beta-User: true) vont vers v2
  - priority: 1
    matchRules:
    - prefixMatch: /
      headerMatches:
      - headerName: X-Beta-User
        exactMatch: "true"
    service: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v2
  # Tous les autres vont vers v1
  - priority: 2
    matchRules:
    - prefixMatch: /
    service: https://www.googleapis.com/compute/v1/projects/${PROJECT_ID}/global/backendServices/backend-v1
EOF

echo ""
echo "Import de l'URL Map..."
gcloud compute url-maps import urlmap-header-routing \
    --source=urlmap-header-routing.yaml \
    --global

echo ""
echo "Mise à jour du proxy..."
gcloud compute target-http-proxies update proxy-http-app \
    --url-map=urlmap-header-routing

echo ""
echo "Configuration terminée !"
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")

# Tester
echo "=== Tests ==="
echo ""
echo "Test utilisateur normal (v1) :"
curl -s http://$LB_IP/ | grep "Version"

echo ""
echo ""
echo "Test utilisateur beta (v2) :"
curl -s -H "X-Beta-User: true" http://$LB_IP/ | grep "Version"

echo ""
echo ""
echo "=== Résumé ==="
echo "Configuration activée !"
echo "  - Utilisateurs normaux → backend-v1"
echo "  - Utilisateurs beta (header X-Beta-User: true) → backend-v2"
echo ""
echo "Cas d'usage :"
echo "  - Tests beta pour utilisateurs spécifiques"
echo "  - A/B testing"
echo "  - Feature flags"
