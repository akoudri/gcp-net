#!/bin/bash
# Lab 10.6 - Exercice 10.6.1 : Créer le sous-réseau pour l'ILB
# Objectif : Créer les sous-réseaux pour l'Internal Load Balancer

set -e

echo "=== Lab 10.6 - Exercice 1 : Créer les sous-réseaux pour l'ILB ==="
echo ""

# Variables
export REGION="europe-west1"

# Sous-réseau pour le proxy-only (requis pour Internal Managed LB)
echo "Création du sous-réseau proxy-only..."
gcloud compute networks subnets create subnet-proxy-only \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.100.0/24 \
    --purpose=REGIONAL_MANAGED_PROXY \
    --role=ACTIVE

echo ""
echo "Création du sous-réseau pour les backends internes..."

# Sous-réseau pour les backends internes
gcloud compute networks subnets create subnet-internal \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.2.0/24

echo ""
echo "Sous-réseaux créés avec succès !"
echo ""
echo "=== Résumé ==="
echo "Sous-réseau proxy-only : 10.0.100.0/24"
echo "  - Purpose : REGIONAL_MANAGED_PROXY"
echo "  - Requis pour Internal Application LB"
echo ""
echo "Sous-réseau internal : 10.0.2.0/24"
echo "  - Pour les backends internes"
