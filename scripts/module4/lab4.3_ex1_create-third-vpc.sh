#!/bin/bash
# Lab 4.3 - Exercice 4.3.1 : Créer un troisième VPC
# Objectif : Créer VPC Gamma pour démontrer la non-transitivité

set -e

echo "=== Lab 4.3 - Exercice 1 : Créer un troisième VPC ==="
echo ""

# Variables
export VPC_GAMMA="vpc-gamma"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "VPC Gamma : $VPC_GAMMA"
echo "Région : $REGION"
echo ""

# Créer VPC Gamma
echo "Création du VPC Gamma..."
gcloud compute networks create $VPC_GAMMA \
    --subnet-mode=custom \
    --description="VPC Gamma pour démontrer la non-transitivité"

gcloud compute networks subnets create subnet-gamma \
    --network=$VPC_GAMMA \
    --region=$REGION \
    --range=10.30.1.0/24

echo ""
echo "VPC Gamma créé avec succès !"
echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu pour VPC Gamma..."
gcloud compute firewall-rules create ${VPC_GAMMA}-allow-internal \
    --network=$VPC_GAMMA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_GAMMA}-allow-ssh-iap \
    --network=$VPC_GAMMA \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo ""

# VM dans VPC Gamma
echo "Création de la VM dans VPC Gamma..."
gcloud compute instances create vm-gamma \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_GAMMA \
    --subnet=subnet-gamma \
    --private-network-ip=10.30.1.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "VM Gamma créée avec succès !"
echo ""

echo "Architecture actuelle :"
echo "Alpha (10.10.0.0/16) ↔ Beta (10.20.0.0/16)    Gamma (10.30.0.0/16)"
echo ""
