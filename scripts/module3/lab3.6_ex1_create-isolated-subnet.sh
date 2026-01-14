#!/bin/bash
# Lab 3.6 - Exercice 3.6.1 : Créer un sous-réseau sans accès Internet
# Objectif : Créer un sous-réseau isolé pour tester Private Google Access

set -e

echo "=== Lab 3.6 - Exercice 1 : Créer un sous-réseau sans accès Internet ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION_EU"
echo ""

# Créer un sous-réseau isolé
echo "Création du sous-réseau isolé..."
gcloud compute networks subnets create subnet-isolated \
    --network=$VPC_NAME \
    --region=$REGION_EU \
    --range=10.3.0.0/24

echo ""
echo "Création de vm-isolated (sans NAT)..."
# Créer une VM dans ce sous-réseau (sans NAT)
gcloud compute instances create vm-isolated \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-isolated \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --scopes=storage-ro

echo ""
echo "Infrastructure créée avec succès !"
echo ""

echo "=== VM créée ==="
gcloud compute instances describe vm-isolated --zone=${REGION_EU}-b --format="table(name,networkInterfaces[0].networkIP)"
echo ""
