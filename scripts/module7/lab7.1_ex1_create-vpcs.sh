#!/bin/bash
# Lab 7.1 - Exercice 7.1.1 : Créer l'infrastructure des deux VPC
# Objectif : Créer les VPC GCP et On-premise avec leurs sous-réseaux et règles de pare-feu

set -e

echo "=== Lab 7.1 - Exercice 1 : Créer l'infrastructure des deux VPC ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet actif : $PROJECT_ID"
echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# ===== VPC "GCP" (Production) =====
echo ">>> Création du VPC GCP (Production)..."
gcloud compute networks create vpc-gcp \
    --subnet-mode=custom \
    --description="VPC simulant l'environnement GCP production"

gcloud compute networks subnets create subnet-gcp \
    --network=vpc-gcp \
    --region=$REGION \
    --range=10.0.0.0/24

echo ""

# ===== VPC "On-premise" (Simulé) =====
echo ">>> Création du VPC On-premise (Simulé)..."
gcloud compute networks create vpc-onprem \
    --subnet-mode=custom \
    --description="VPC simulant le datacenter on-premise"

gcloud compute networks subnets create subnet-onprem \
    --network=vpc-onprem \
    --region=$REGION \
    --range=192.168.0.0/24

echo ""

# Règles de pare-feu pour les deux VPC
echo ">>> Configuration des règles de pare-feu..."
for VPC in vpc-gcp vpc-onprem; do
    echo "  - Règles pour $VPC"
    gcloud compute firewall-rules create ${VPC}-allow-internal \
        --network=$VPC \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8,192.168.0.0/16

    gcloud compute firewall-rules create ${VPC}-allow-ssh-iap \
        --network=$VPC \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20
done

echo ""
echo "=== Infrastructure créée avec succès ==="
echo ""
echo "VPCs créés :"
gcloud compute networks list --filter="name:(vpc-gcp OR vpc-onprem)"
echo ""
echo "Sous-réseaux créés :"
gcloud compute networks subnets list --filter="network:(vpc-gcp OR vpc-onprem)"
