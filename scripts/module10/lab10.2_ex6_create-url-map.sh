#!/bin/bash
# Lab 10.2 - Exercice 10.2.6 : Créer l'URL Map
# Objectif : Créer l'URL Map avec routage vers les différents backends

set -e

echo "=== Lab 10.2 - Exercice 6 : Créer l'URL Map ==="
echo ""

# URL Map avec routage
echo "Création de l'URL Map urlmap-app..."
gcloud compute url-maps create urlmap-app \
    --default-service=backend-web

echo ""
echo "Ajout du path matcher pour l'API..."

# Path matcher pour l'API
gcloud compute url-maps add-path-matcher urlmap-app \
    --path-matcher-name=api-matcher \
    --default-service=backend-api \
    --path-rules="/api/*=backend-api"

gcloud compute url-maps add-host-rule urlmap-app \
    --hosts="*" \
    --path-matcher-name=api-matcher

echo ""
echo "Ajout du path matcher pour le contenu statique..."

# Ajouter le routage pour le contenu statique
gcloud compute url-maps add-path-matcher urlmap-app \
    --path-matcher-name=static-matcher \
    --default-service=backend-web \
    --backend-bucket-path-rules="/static/*=bucket-static"

echo ""
echo "URL Map créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "URL Map : urlmap-app"
echo "Règles de routage :"
echo "  - /api/* → backend-api"
echo "  - /static/* → bucket-static"
echo "  - /* (défaut) → backend-web"
