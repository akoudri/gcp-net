#!/bin/bash
# Lab 7.2 - Exercice 7.2.1 : Explorer la configuration BGP
# Objectif : Comprendre la configuration BGP dans Cloud Router

set -e

echo "=== Lab 7.2 - Exercice 1 : Explorer la configuration BGP ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Voir la configuration complète du Cloud Router GCP
echo "=== Configuration complète du Cloud Router GCP ==="
gcloud compute routers describe router-gcp --region=$REGION

echo ""

# Détails des interfaces BGP
echo "=== Détails des interfaces BGP ==="
gcloud compute routers describe router-gcp --region=$REGION \
    --format="yaml(interfaces)"

echo ""

# Détails des peers BGP
echo "=== Détails des peers BGP ==="
gcloud compute routers describe router-gcp --region=$REGION \
    --format="yaml(bgpPeers)"

echo ""
echo "=== Exploration terminée ==="
