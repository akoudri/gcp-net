#!/bin/bash
# Lab 4.2 - Exercice 4.2.3 : Activer l'export/import des routes personnalisées
# Objectif : Configurer l'échange des routes personnalisées entre VPC peerés

set -e

echo "=== Lab 4.2 - Exercice 3 : Activer l'export/import des routes personnalisées ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"

echo "Configuration de l'échange des routes personnalisées..."
echo ""

# Mettre à jour le peering côté Alpha pour EXPORTER les routes
echo "Activation de l'export des routes depuis VPC Alpha..."
gcloud compute networks peerings update peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --export-custom-routes

echo ""

# Mettre à jour le peering côté Beta pour IMPORTER les routes
echo "Activation de l'import des routes dans VPC Beta..."
gcloud compute networks peerings update peering-beta-to-alpha \
    --network=$VPC_BETA \
    --import-custom-routes

echo ""
echo "Configuration terminée !"
echo ""

# Attendre un peu pour la propagation
echo "Attente de la propagation des routes..."
sleep 10

# Vérifier la configuration
echo "=== Configuration du peering Alpha ==="
gcloud compute networks peerings describe peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --format="yaml(exportCustomRoutes,importCustomRoutes)"

echo ""
echo "=== Configuration du peering Beta ==="
gcloud compute networks peerings describe peering-beta-to-alpha \
    --network=$VPC_BETA \
    --format="yaml(exportCustomRoutes,importCustomRoutes)"

echo ""

echo "Questions à considérer :"
echo "1. Pourquoi faut-il configurer les deux côtés du peering ?"
echo "2. Que se passe-t-il si seulement un côté active l'export ?"
