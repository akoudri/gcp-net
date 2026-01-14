#!/bin/bash
# Lab 10.10 - Exercice 10.10.5 : Invalider le cache
# Objectif : Invalider le cache CDN pour forcer le rafraîchissement

set -e

echo "=== Lab 10.10 - Exercice 5 : Invalider le cache ==="
echo ""

echo "Options d'invalidation :"
echo "  1. Invalider un fichier spécifique"
echo "  2. Invalider un préfixe (ex: /static/*)"
echo "  3. Invalider tout le cache"
echo ""

read -p "Choisissez une option (1, 2 ou 3) : " CHOICE

case $CHOICE in
    1)
        read -p "Entrez le path du fichier (ex: /static/style.css) : " PATH
        echo ""
        echo "Invalidation de $PATH..."
        gcloud compute url-maps invalidate-cdn-cache urlmap-app \
            --path="$PATH" \
            --global
        ;;
    2)
        read -p "Entrez le préfixe (ex: /static/*) : " PATH
        echo ""
        echo "Invalidation de $PATH..."
        gcloud compute url-maps invalidate-cdn-cache urlmap-app \
            --path="$PATH" \
            --global
        ;;
    3)
        echo ""
        echo "Invalidation de tout le cache..."
        gcloud compute url-maps invalidate-cdn-cache urlmap-app \
            --path="/*" \
            --global
        ;;
    *)
        echo "Choix invalide"
        exit 1
        ;;
esac

echo ""
echo "Invalidation en cours..."
echo ""
echo "⚠️  IMPORTANT :"
echo "  - L'invalidation peut prendre plusieurs minutes à se propager"
echo "  - Les caches distribués globalement sont vidés progressivement"
echo "  - Utilisez l'invalidation avec modération (quotas limités)"
echo ""
echo "Cas d'usage :"
echo "  - Mise à jour d'un fichier statique"
echo "  - Correction d'un bug critique"
echo "  - Déploiement d'une nouvelle version"
