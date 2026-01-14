#!/bin/bash
# Lab 7.2 - Exercice 7.2.4 : Configurer des annonces personnalisées
# Objectif : Configurer des routes personnalisées à annoncer via BGP

set -e

echo "=== Lab 7.2 - Exercice 4 : Configurer des annonces personnalisées ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Voir le mode d'annonce actuel
echo "=== Mode d'annonce actuel ==="
gcloud compute routers describe router-gcp --region=$REGION \
    --format="get(bgp.advertiseMode)"

echo ""

# Passer en mode custom pour annoncer des routes spécifiques
echo ">>> Configuration du mode d'annonce personnalisé..."
gcloud compute routers update router-gcp \
    --region=$REGION \
    --advertisement-mode=CUSTOM \
    --set-advertisement-groups=ALL_SUBNETS \
    --set-advertisement-ranges=172.16.0.0/16:route-vers-autre-dc

echo ""

# Vérifier la configuration
echo "=== Configuration BGP mise à jour ==="
gcloud compute routers describe router-gcp --region=$REGION \
    --format="yaml(bgp)"

echo ""
echo ">>> Attente de la propagation (30 secondes)..."
sleep 30

# Voir si la route personnalisée est annoncée
echo "=== Routes apprises par router-onprem (avec route personnalisée) ==="
gcloud compute routers get-status router-onprem --region=$REGION \
    --format="yaml(result.bestRoutes)"

echo ""
echo "=== Configuration terminée ==="
