#!/bin/bash
# Lab 3.4 - Exercice 3.4.3 : Configurer des annonces personnalisées
# Objectif : Configurer les annonces de routes personnalisées

set -e

echo "=== Lab 3.4 - Exercice 3 : Configurer des annonces personnalisées ==="
echo ""

# Variables
export REGION_EU="europe-west1"

echo "Région : $REGION_EU"
echo ""

# Configurer le router pour annoncer des plages personnalisées
echo "Configuration des annonces personnalisées..."
gcloud compute routers update my-cloud-router \
    --region=$REGION_EU \
    --advertisement-mode=CUSTOM \
    --set-advertisement-groups=ALL_SUBNETS \
    --set-advertisement-ranges=10.100.0.0/16,10.200.0.0/16

echo ""
echo "Annonces personnalisées configurées avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration BGP ==="
gcloud compute routers describe my-cloud-router \
    --region=$REGION_EU \
    --format="yaml(bgp)"
echo ""

echo "Questions à considérer :"
echo "1. Quelle est la différence entre DEFAULT et CUSTOM pour advertisement-mode ?"
echo "2. Pourquoi voudrait-on annoncer des plages supplémentaires ?"
echo ""
