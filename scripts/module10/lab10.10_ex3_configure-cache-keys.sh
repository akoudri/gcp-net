#!/bin/bash
# Lab 10.10 - Exercice 10.10.3 : Configurer les Cache Keys
# Objectif : Personnaliser les clés de cache CDN

set -e

echo "=== Lab 10.10 - Exercice 3 : Configurer les Cache Keys ==="
echo ""

echo "Par défaut, la cache key inclut : protocol + host + path + query string"
echo ""
echo "Options disponibles :"
echo "  1. Exclure les query strings"
echo "  2. Inclure seulement certains query params"
echo ""

read -p "Choisissez une option (1 ou 2) : " CHOICE

case $CHOICE in
    1)
        echo ""
        echo "Configuration : Exclure les query strings..."
        gcloud compute backend-services update backend-web \
            --cache-key-include-protocol \
            --cache-key-include-host \
            --no-cache-key-include-query-string \
            --global

        echo ""
        echo "Configuration appliquée !"
        echo "Cache key = protocol + host + path (sans query string)"
        ;;
    2)
        echo ""
        read -p "Entrez les query params à inclure (séparés par des virgules, ex: version,locale) : " PARAMS

        echo ""
        echo "Configuration : Inclure seulement $PARAMS..."
        gcloud compute backend-services update backend-web \
            --cache-key-query-string-whitelist=$PARAMS \
            --global

        echo ""
        echo "Configuration appliquée !"
        echo "Cache key inclut seulement les query params : $PARAMS"
        ;;
    *)
        echo "Choix invalide"
        exit 1
        ;;
esac

echo ""
echo "Vérification de la configuration..."
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(cdnPolicy.cacheKeyPolicy)"

echo ""
echo "Cache Keys configurées avec succès !"
echo ""
echo "=== Exemples ==="
echo "Si cache-key-include-query-string = false :"
echo "  /page?id=1 et /page?id=2 → même cache entry"
echo ""
echo "Si cache-key-query-string-whitelist = [version] :"
echo "  /page?version=1&id=1 et /page?version=1&id=2 → même cache entry"
echo "  /page?version=1 et /page?version=2 → cache entries différentes"
