#!/bin/bash
# Lab 4.1 - Exercice 4.1.2 : Déployer les VMs de test
# Objectif : Créer les règles de pare-feu et déployer les VMs dans chaque VPC

set -e

echo "=== Lab 4.1 - Exercice 2 : Déployer les VMs de test ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "VPC Alpha : $VPC_ALPHA"
echo "VPC Beta : $VPC_BETA"
echo "Zone : $ZONE"
echo ""

# Règles de pare-feu pour VPC Alpha
echo "Création des règles de pare-feu pour VPC Alpha..."
gcloud compute firewall-rules create ${VPC_ALPHA}-allow-internal \
    --network=$VPC_ALPHA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_ALPHA}-allow-ssh-iap \
    --network=$VPC_ALPHA \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo ""

# Règles de pare-feu pour VPC Beta
echo "Création des règles de pare-feu pour VPC Beta..."
gcloud compute firewall-rules create ${VPC_BETA}-allow-internal \
    --network=$VPC_BETA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_BETA}-allow-ssh-iap \
    --network=$VPC_BETA \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo ""

# VM dans VPC Alpha
echo "Création de la VM dans VPC Alpha..."
gcloud compute instances create vm-alpha \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_ALPHA \
    --subnet=subnet-alpha \
    --private-network-ip=10.10.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""

# VM dans VPC Beta
echo "Création de la VM dans VPC Beta..."
gcloud compute instances create vm-beta \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_BETA \
    --subnet=subnet-beta \
    --private-network-ip=10.20.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "VMs créées avec succès !"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi utiliser --no-address pour les VMs ?"
echo "2. Que permet la plage 35.235.240.0/20 dans les règles SSH ?"
