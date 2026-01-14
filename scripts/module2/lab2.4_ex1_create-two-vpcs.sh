#!/bin/bash
# Lab 2.4 - Exercice 2.4.1 : Créer les deux VPC pour Multi-NIC
# Objectif : Préparer l'infrastructure pour une VM multi-interfaces

set -e

echo "=== Lab 2.4 - Exercice 1 : Créer deux VPC ==="
echo ""

# Variables
export REGION="europe-west1"
export ZONE="europe-west1-b"

# VPC A
echo "Création du VPC-A..."
gcloud compute networks create vpc-a \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-a \
    --network=vpc-a \
    --region=$REGION \
    --range=10.1.0.0/24

echo ""

# VPC B
echo "Création du VPC-B..."
gcloud compute networks create vpc-b \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-b \
    --network=vpc-b \
    --region=$REGION \
    --range=10.2.0.0/24

echo ""

# Règles de pare-feu pour les deux VPC
echo "Configuration des règles de pare-feu..."
for VPC in vpc-a vpc-b; do
    gcloud compute firewall-rules create ${VPC}-allow-internal \
        --network=$VPC \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8

    gcloud compute firewall-rules create ${VPC}-allow-ssh \
        --network=$VPC \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20  # Plage IAP
done

echo ""
echo "Infrastructure VPC créée avec succès !"
echo ""

# Vérifier
echo "=== VPCs créés ==="
gcloud compute networks list --filter="name:(vpc-a OR vpc-b)"
