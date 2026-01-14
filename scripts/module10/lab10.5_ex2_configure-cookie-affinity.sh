#!/bin/bash
# Lab 10.5 - Exercice 10.5.2 : Configurer l'affinité par cookie
# Objectif : Activer la session affinity avec un cookie généré par le LB

set -e

echo "=== Lab 10.5 - Exercice 2 : Configurer l'affinité par cookie ==="
echo ""

# Activer GENERATED_COOKIE sur le backend service
echo "Activation de l'affinité par cookie sur backend-web..."
gcloud compute backend-services update backend-web \
    --session-affinity=GENERATED_COOKIE \
    --affinity-cookie-ttl=3600 \
    --global

echo ""
echo "Vérification de la configuration..."

# Vérifier la configuration
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(sessionAffinity,affinityCookieTtlSec)"

echo ""
echo "Session affinity configurée avec succès !"
echo ""
echo "=== Résumé ==="
echo "Backend Service : backend-web"
echo "Session Affinity : GENERATED_COOKIE"
echo "Cookie TTL : 3600 secondes (1 heure)"
echo ""
echo "Le Load Balancer générera un cookie pour maintenir les sessions"
echo "sur le même backend pendant 1 heure."
