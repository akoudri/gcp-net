#!/bin/bash
# Lab 11.2 - Exercice 11.2.2 : Activer les VPC Flow Logs (configuration basique)
# Objectif : Activer les Flow Logs avec les paramètres par défaut

set -e

echo "=== Lab 11.2 - Exercice 2 : Activer les VPC Flow Logs (basique) ==="
echo ""

# Variables
export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Activer les Flow Logs avec les paramètres par défaut
echo "Activation des Flow Logs sur subnet-monitored..."
gcloud compute networks subnets update subnet-monitored \
    --region=$REGION \
    --enable-flow-logs

echo ""
echo "Flow Logs activés avec succès !"
echo ""

# Vérifier l'activation
echo "=== Vérification de la configuration ==="
gcloud compute networks subnets describe subnet-monitored \
    --region=$REGION \
    --format="yaml(enableFlowLogs,logConfig)"

echo ""
echo "Les Flow Logs sont maintenant activés avec la configuration par défaut."
echo "Note: Les logs apparaîtront dans Cloud Logging après quelques minutes de trafic."
