#!/bin/bash
# Lab 3.2 - Exercice 3.2.3 : Déployer les VMs de test
# Objectif : Créer les VMs pour tester les routes personnalisées

set -e

echo "=== Lab 3.2 - Exercice 3 : Déployer les VMs de test ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"
export REGION_US="us-central1"

echo "Déploiement de vm-eu en Europe..."
# VM en Europe
gcloud compute instances create vm-eu \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --can-ip-forward \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        apt-get update && apt-get install -y tcpdump traceroute'

echo ""
echo "Déploiement de vm-us aux US..."
# VM aux US
gcloud compute instances create vm-us \
    --zone=${REGION_US}-a \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-us \
    --private-network-ip=10.2.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y tcpdump traceroute'

echo ""
echo "VMs déployées avec succès !"
echo ""

echo "=== VMs créées ==="
gcloud compute instances list --filter="name:(vm-eu OR vm-us)"
echo ""
