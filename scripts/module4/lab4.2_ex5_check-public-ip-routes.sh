#!/bin/bash
# Lab 4.2 - Exercice 4.2.5 : Comprendre les routes avec IP publiques
# Objectif : Examiner les options pour les routes avec IP publiques

set -e

echo "=== Lab 4.2 - Exercice 5 : Comprendre les routes avec IP publiques ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"

echo "Vérification des options pour les routes avec IP publiques..."
echo ""

# Vérifier les options pour les routes avec IP publiques
echo "=== Configuration des routes avec IP publiques pour peering Alpha ==="
gcloud compute networks peerings describe peering-alpha-to-beta \
    --network=$VPC_ALPHA \
    --format="yaml(exportSubnetRoutesWithPublicIp,importSubnetRoutesWithPublicIp)"

echo ""

echo "Observation :"
echo "Par défaut, ces options sont activées"
echo "Elles concernent les plages secondaires (GKE) qui peuvent avoir des IPs publiques"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi ces options sont-elles importantes pour GKE ?"
echo "2. Dans quel cas désactiveriez-vous ces options ?"
