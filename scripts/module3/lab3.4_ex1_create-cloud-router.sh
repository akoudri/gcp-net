#!/bin/bash
# Lab 3.4 - Exercice 3.4.1 : Créer un Cloud Router
# Objectif : Créer et configurer un Cloud Router

set -e

echo "=== Lab 3.4 - Exercice 1 : Créer un Cloud Router ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION_EU"
echo ""

# Créer un Cloud Router avec un ASN privé
echo "Création du Cloud Router avec ASN 65001..."
gcloud compute routers create my-cloud-router \
    --network=$VPC_NAME \
    --region=$REGION_EU \
    --asn=65001 \
    --description="Cloud Router pour lab BGP"

echo ""
echo "Cloud Router créé avec succès !"
echo ""

# Vérifier la création
echo "=== Détails du Cloud Router ==="
gcloud compute routers describe my-cloud-router \
    --region=$REGION_EU
echo ""

echo "Questions à considérer :"
echo "1. Qu'est-ce qu'un ASN (Autonomous System Number) ?"
echo "2. Pourquoi utilise-t-on un ASN dans la plage 64512-65534 ?"
echo ""
