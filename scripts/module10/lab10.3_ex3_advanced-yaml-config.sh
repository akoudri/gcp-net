#!/bin/bash
# Lab 10.3 - Exercice 10.3.3 : Configuration YAML avancée
# Objectif : Créer une configuration URL Map avancée avec YAML

set -e

echo "=== Lab 10.3 - Exercice 3 : Configuration YAML avancée ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

# Exporter l'URL Map actuel
echo "Export de l'URL Map actuel..."
gcloud compute url-maps export urlmap-app \
    --destination=urlmap-export.yaml \
    --global

echo ""
echo "Affichage de la structure exportée :"
cat urlmap-export.yaml

echo ""
echo ""
echo "Création d'une configuration avancée..."

# Créer une configuration avancée
cat > urlmap-advanced.yaml << 'EOF'
name: urlmap-advanced
defaultService: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-web
hostRules:
- hosts:
  - "*"
  pathMatcher: main-matcher
pathMatchers:
- name: main-matcher
  defaultService: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-web
  routeRules:
  # Route basée sur le header
  - priority: 1
    matchRules:
    - prefixMatch: /api
      headerMatches:
      - headerName: X-API-Version
        exactMatch: "v2"
    service: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-api
  # Route par défaut pour /api
  - priority: 2
    matchRules:
    - prefixMatch: /api
    service: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendServices/backend-api
  # Contenu statique
  - priority: 3
    matchRules:
    - prefixMatch: /static
    service: https://www.googleapis.com/compute/v1/projects/PROJECT_ID/global/backendBuckets/bucket-static
EOF

# Remplacer PROJECT_ID
sed -i "s/PROJECT_ID/$PROJECT_ID/g" urlmap-advanced.yaml

echo ""
echo "Configuration YAML avancée créée : urlmap-advanced.yaml"
echo ""
echo "Cette configuration inclut :"
echo "  - Routage basé sur le header X-API-Version"
echo "  - Routage par path avec priorités"
echo "  - Contenu statique"
echo ""
echo "Pour importer cette configuration :"
echo "  gcloud compute url-maps import urlmap-advanced --source=urlmap-advanced.yaml --global"
