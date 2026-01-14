#!/bin/bash
# Lab 5.1 - Exercice 5.1.4 : Activer Private Google Access
# Objectif : Activer PGA sur le sous-réseau

set -e

echo "=== Lab 5.1 - Exercice 4 : Activer Private Google Access ==="
echo ""

# Variables
export VPC_NAME="vpc-private-access"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Activer PGA sur le sous-réseau
echo "Activation de Private Google Access sur subnet-pga..."
gcloud compute networks subnets update subnet-pga \
    --region=$REGION \
    --enable-private-ip-google-access

echo ""
echo "PGA activé avec succès !"
echo ""

# Vérifier l'activation
echo "=== Vérification de l'état de PGA ==="
PGA_STATUS=$(gcloud compute networks subnets describe subnet-pga \
    --region=$REGION \
    --format="get(privateIpGoogleAccess)")
echo "Private Google Access: $PGA_STATUS"
echo "(Attendu: True)"
echo ""

echo "=== Private Google Access activé ! ==="
echo ""
echo "Les VMs dans ce sous-réseau peuvent maintenant accéder aux APIs Google"
echo "sans avoir besoin d'une IP externe."
