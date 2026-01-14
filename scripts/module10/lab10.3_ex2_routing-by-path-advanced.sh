#!/bin/bash
# Lab 10.3 - Exercice 10.3.2 : Routage par Path avancé
# Objectif : Configurer le routage avec plusieurs paths

set -e

echo "=== Lab 10.3 - Exercice 2 : Routage par Path avancé ==="
echo ""

# URL Map avec paths multiples
echo "Création de l'URL Map urlmap-paths..."
gcloud compute url-maps create urlmap-paths \
    --default-service=backend-web

echo ""
echo "Ajout des règles de path..."

# Créer un path matcher complexe
gcloud compute url-maps add-path-matcher urlmap-paths \
    --path-matcher-name=complex-matcher \
    --default-service=backend-web \
    --path-rules="/api/v1/*=backend-api,/api/v2/*=backend-api,/static/*=bucket-static,/images/*=bucket-static"

gcloud compute url-maps add-host-rule urlmap-paths \
    --hosts="*" \
    --path-matcher-name=complex-matcher

echo ""
echo "URL Map avec routage avancé créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "URL Map : urlmap-paths"
echo "Règles de routage :"
echo "  - /api/v1/* → backend-api"
echo "  - /api/v2/* → backend-api"
echo "  - /static/* → bucket-static"
echo "  - /images/* → bucket-static"
echo "  - /* (défaut) → backend-web"
echo ""
echo "Pour utiliser cette configuration :"
echo "  gcloud compute target-http-proxies update proxy-http-app --url-map=urlmap-paths"
