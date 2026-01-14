#!/bin/bash
# Lab 4.3 - Exercice 4.3.7 : Configurer le routage via le hub
# Objectif : Configurer les routes et l'échange pour le transit

set -e

echo "=== Lab 4.3 - Exercice 7 : Configurer le routage via le hub ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"
export VPC_GAMMA="vpc-gamma"
export ZONE="europe-west1-b"

echo "Configuration de l'échange de routes pour le transit via Beta..."
echo ""

# Activer l'export des routes personnalisées sur les peerings
echo "Activation de l'export/import des routes personnalisées..."
gcloud compute networks peerings update peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --export-custom-routes

gcloud compute networks peerings update peering-beta-to-alpha \
    --network=$VPC_BETA \
    --import-custom-routes \
    --export-custom-routes

gcloud compute networks peerings update peering-beta-to-gamma \
    --network=$VPC_BETA \
    --import-custom-routes \
    --export-custom-routes

gcloud compute networks peerings update peering-gamma-to-beta \
    --network=$VPC_GAMMA \
    --import-custom-routes

echo ""
echo "Configuration des peerings terminée."
echo ""

# Route dans VPC Alpha vers Gamma via vm-beta
echo "Création de la route Alpha → Gamma via vm-beta..."
gcloud compute routes create route-alpha-to-gamma-via-beta \
    --network=$VPC_ALPHA \
    --destination-range=10.30.0.0/16 \
    --next-hop-instance=vm-beta \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

echo ""

# Route dans VPC Gamma vers Alpha via vm-beta
echo "Création de la route Gamma → Alpha via vm-beta..."
gcloud compute routes create route-gamma-to-alpha-via-beta \
    --network=$VPC_GAMMA \
    --destination-range=10.10.0.0/16 \
    --next-hop-instance=vm-beta \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

echo ""
echo "Routes personnalisées créées !"
echo ""

echo "Note : Cette configuration est complexe et nécessite que vm-beta soit dans le chemin réseau."
echo "En production, utilisez Network Connectivity Center pour un transit managé."
echo ""
