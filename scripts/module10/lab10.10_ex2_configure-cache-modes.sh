#!/bin/bash
# Lab 10.10 - Exercice 10.10.2 : Modes de cache CDN
# Objectif : Configurer différents modes de cache pour Cloud CDN

set -e

echo "=== Lab 10.10 - Exercice 2 : Modes de cache CDN ==="
echo ""

echo "Modes de cache disponibles :"
echo "  - CACHE_ALL_STATIC : Cache automatique du contenu statique"
echo "  - USE_ORIGIN_HEADERS : Respecte les headers Cache-Control"
echo "  - FORCE_CACHE_ALL : Cache TOUT le contenu"
echo ""

read -p "Choisissez un mode (1=CACHE_ALL_STATIC, 2=USE_ORIGIN_HEADERS, 3=FORCE_CACHE_ALL) : " CHOICE

case $CHOICE in
    1)
        MODE="CACHE_ALL_STATIC"
        ;;
    2)
        MODE="USE_ORIGIN_HEADERS"
        ;;
    3)
        MODE="FORCE_CACHE_ALL"
        ;;
    *)
        echo "Choix invalide, utilisation de CACHE_ALL_STATIC"
        MODE="CACHE_ALL_STATIC"
        ;;
esac

echo ""
echo "Configuration du mode $MODE..."

# Configurer le mode de cache
gcloud compute backend-services update backend-web \
    --cache-mode=$MODE \
    --global

echo ""
echo "Vérification de la configuration..."
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(cdnPolicy.cacheMode)"

echo ""
echo "Mode de cache configuré avec succès !"
echo ""
echo "=== Résumé ==="
echo "Mode sélectionné : $MODE"
echo ""

case $MODE in
    "CACHE_ALL_STATIC")
        echo "Comportement :"
        echo "  - Cache automatique : images, CSS, JS, fonts, PDF"
        echo "  - Idéal pour sites web classiques"
        ;;
    "USE_ORIGIN_HEADERS")
        echo "Comportement :"
        echo "  - Respecte les headers Cache-Control de l'origin"
        echo "  - Plus flexible, nécessite config applicative"
        echo "  - Idéal pour APIs avec cache contrôlé"
        ;;
    "FORCE_CACHE_ALL")
        echo "Comportement :"
        echo "  - Cache TOUT le contenu (ignore headers)"
        echo "  - Attention aux données dynamiques !"
        echo "  - Idéal pour CDN origin 100% statique"
        ;;
esac
