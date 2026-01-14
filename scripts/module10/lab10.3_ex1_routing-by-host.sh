#!/bin/bash
# Lab 10.3 - Exercice 10.3.1 : Routage par Host
# Objectif : Configurer le routage basé sur le hostname

set -e

echo "=== Lab 10.3 - Exercice 1 : Routage par Host ==="
echo ""

# Créer un URL Map avec routage par host
echo "Création de l'URL Map urlmap-multihost..."
gcloud compute url-maps create urlmap-multihost \
    --default-service=backend-web

echo ""
echo "Ajout des host rules..."

# Ajouter les host rules
gcloud compute url-maps add-path-matcher urlmap-multihost \
    --path-matcher-name=www-matcher \
    --default-service=backend-web

gcloud compute url-maps add-host-rule urlmap-multihost \
    --hosts="www.example.com,example.com" \
    --path-matcher-name=www-matcher

gcloud compute url-maps add-path-matcher urlmap-multihost \
    --path-matcher-name=api-matcher \
    --default-service=backend-api

gcloud compute url-maps add-host-rule urlmap-multihost \
    --hosts="api.example.com" \
    --path-matcher-name=api-matcher

echo ""
echo "URL Map avec routage par host créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "URL Map : urlmap-multihost"
echo "Règles de routage :"
echo "  - www.example.com, example.com → backend-web"
echo "  - api.example.com → backend-api"
echo ""
echo "Pour utiliser cette configuration :"
echo "  gcloud compute target-http-proxies update proxy-http-app --url-map=urlmap-multihost"
