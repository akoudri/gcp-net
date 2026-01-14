#!/bin/bash
# Lab 11.2 - Exercice 11.2.3 : Configurer les paramètres avancés
# Objectif : Optimiser les paramètres des Flow Logs pour la production

set -e

echo "=== Lab 11.2 - Exercice 3 : Configurer les paramètres avancés ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Configuration optimisée pour la production :"
echo "  - Intervalle d'agrégation : 30 secondes"
echo "  - Sampling : 50% (0.5)"
echo "  - Métadonnées : Toutes incluses"
echo ""

# Configurer avec des paramètres optimisés pour la production
echo "Mise à jour de la configuration des Flow Logs..."
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --logging-aggregation-interval=INTERVAL_30_SEC \
    --logging-flow-sampling=0.5 \
    --logging-metadata=INCLUDE_ALL_METADATA

echo ""
echo "Configuration mise à jour avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration actuelle ==="
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(logConfig)"

echo ""
echo "Paramètres appliqués :"
echo "  - INTERVAL_30_SEC : Bon compromis entre granularité et coût"
echo "  - Sampling 0.5 : Capture 50% des flux (réduit les coûts)"
echo "  - INCLUDE_ALL_METADATA : Enrichit les logs avec noms de VMs, VPC, etc."
