#!/bin/bash
# Lab 5.5 - Exercice 5.5.1 : Créer un sous-réseau pour PSC
# Objectif : Préparer l'infrastructure pour Private Service Connect

set -e

echo "=== Lab 5.5 - Exercice 1 : Créer un sous-réseau pour PSC ==="
echo ""

export VPC_NAME="vpc-private-access"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Sous-réseau dédié pour PSC
echo "Création du sous-réseau dédié pour PSC..."
gcloud compute networks subnets create subnet-psc \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.1.0.0/24 \
    --enable-private-ip-google-access

echo ""
echo "=== Sous-réseau PSC créé ! ==="
echo ""
echo "Nom : subnet-psc"
echo "Range : 10.1.0.0/24"
echo "PGA : Activé"
echo ""
echo "Ce sous-réseau servira pour les endpoints PSC et les VMs clientes."
