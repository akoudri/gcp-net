#!/bin/bash
# Lab 4.9 - Exercice 4.9.3 : Déployer les VMs
# Objectif : Déployer des VMs dans tous les environnements

set -e

echo "=== Lab 4.9 - Exercice 3 : Déployer les VMs ==="
echo ""

# Variables
export VPC_HUB="vpc-hub"
export VPC_PARTNER="vpc-partner"
export ZONE="europe-west1-b"

echo "Déploiement des VMs dans l'architecture hybride..."
echo ""

# VM Production
echo "Création de vm-prod..."
gcloud compute instances create vm-prod \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_HUB --subnet=subnet-prod \
    --private-network-ip=10.10.0.10 --no-address \
    --tags=prod,internal \
    --image-family=debian-11 --image-project=debian-cloud

echo ""

# VM Staging
echo "Création de vm-staging..."
gcloud compute instances create vm-staging \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_HUB --subnet=subnet-staging \
    --private-network-ip=10.20.0.10 --no-address \
    --tags=staging,internal \
    --image-family=debian-11 --image-project=debian-cloud

echo ""

# VM Dev
echo "Création de vm-dev..."
gcloud compute instances create vm-dev \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_HUB --subnet=subnet-dev \
    --private-network-ip=10.30.0.10 --no-address \
    --tags=dev,internal \
    --image-family=debian-11 --image-project=debian-cloud

echo ""

# VM Partenaire
echo "Création de vm-partner..."
gcloud compute instances create vm-partner \
    --zone=$ZONE --machine-type=e2-micro \
    --network=$VPC_PARTNER --subnet=subnet-partner \
    --private-network-ip=10.200.0.10 --no-address \
    --tags=partner,external \
    --image-family=debian-11 --image-project=debian-cloud

echo ""
echo "Toutes les VMs déployées avec succès !"
echo ""

# Afficher les VMs
echo "=== VMs déployées ==="
gcloud compute instances list --filter="zone:$ZONE"
