#!/bin/bash
# Lab 3.5 - Exercice 3.5.1 : Créer une VM sans IP externe
# Objectif : Préparer une VM pour tester Cloud NAT

set -e

echo "=== Lab 3.5 - Exercice 1 : Créer une VM sans IP externe ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION_EU"
echo ""

# Créer une VM sans IP externe pour tester Cloud NAT
echo "Création de vm-nat-test..."
gcloud compute instances create vm-nat-test \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils'

echo ""
echo "VM créée avec succès !"
echo ""

# Vérifier qu'elle n'a pas d'IP externe
echo "=== Vérification : accessConfigs (devrait être vide) ==="
gcloud compute instances describe vm-nat-test \
    --zone=${REGION_EU}-b \
    --format="get(networkInterfaces[0].accessConfigs)"
echo ""

echo "Si vide, la VM n'a pas d'IP externe."
echo ""
