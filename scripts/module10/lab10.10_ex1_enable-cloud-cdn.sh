#!/bin/bash
# Lab 10.10 - Exercice 10.10.1 : Activer Cloud CDN
# Objectif : Activer Cloud CDN sur le backend web

set -e

echo "=== Lab 10.10 - Exercice 1 : Activer Cloud CDN ==="
echo ""

# Activer Cloud CDN sur le backend web
echo "Activation de Cloud CDN sur backend-web..."
gcloud compute backend-services update backend-web \
    --enable-cdn \
    --cache-mode=CACHE_ALL_STATIC \
    --default-ttl=3600 \
    --max-ttl=86400 \
    --global

echo ""
echo "Vérification de la configuration..."

# Vérifier
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(enableCDN,cdnPolicy)"

echo ""
echo "Cloud CDN activé avec succès !"
echo ""
echo "=== Résumé ==="
echo "Backend Service : backend-web"
echo "Cloud CDN : Activé"
echo "Cache Mode : CACHE_ALL_STATIC"
echo "Default TTL : 3600s (1 heure)"
echo "Max TTL : 86400s (24 heures)"
echo ""
echo "Contenu mis en cache automatiquement :"
echo "  - Images (jpg, png, gif, webp, ico)"
echo "  - CSS, JavaScript"
echo "  - Fonts (woff, woff2)"
echo "  - Documents (pdf)"
