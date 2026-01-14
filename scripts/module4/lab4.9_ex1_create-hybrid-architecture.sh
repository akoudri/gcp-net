#!/bin/bash
# Lab 4.9 - Exercice 4.9.1 : Créer l'architecture hybride
# Objectif : Créer une architecture combinant Shared VPC (simulé) et Peering

set -e

echo "=== Lab 4.9 - Exercice 1 : Créer l'architecture hybride ==="
echo ""

# Variables
export VPC_HUB="vpc-hub"
export VPC_PARTNER="vpc-partner"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "VPC Hub : $VPC_HUB"
echo "VPC Partner : $VPC_PARTNER"
echo "Région : $REGION"
echo ""

# 1. Créer le VPC Hub (simule Shared VPC hôte)
echo "=== Création du VPC Hub (simule Shared VPC) ==="
gcloud compute networks create $VPC_HUB \
    --subnet-mode=custom \
    --description="VPC Hub - simule Shared VPC"

# Sous-réseaux internes
echo "Création des sous-réseaux internes..."
gcloud compute networks subnets create subnet-prod \
    --network=$VPC_HUB --region=$REGION --range=10.10.0.0/24

gcloud compute networks subnets create subnet-staging \
    --network=$VPC_HUB --region=$REGION --range=10.20.0.0/24

gcloud compute networks subnets create subnet-dev \
    --network=$VPC_HUB --region=$REGION --range=10.30.0.0/24

echo ""

# 2. Créer le VPC Partenaire (autre organisation simulée)
echo "=== Création du VPC Partenaire ==="
gcloud compute networks create $VPC_PARTNER \
    --subnet-mode=custom \
    --description="VPC Partenaire - autre organisation"

gcloud compute networks subnets create subnet-partner \
    --network=$VPC_PARTNER --region=$REGION --range=10.200.0.0/24

echo ""

# 3. Règles de pare-feu pour Hub
echo "=== Création des règles de pare-feu Hub ==="
gcloud compute firewall-rules create ${VPC_HUB}-allow-internal \
    --network=$VPC_HUB --allow=tcp,udp,icmp --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_HUB}-allow-ssh-iap \
    --network=$VPC_HUB --allow=tcp:22 --source-ranges=35.235.240.0/20

echo ""

# Règles de pare-feu pour Partenaire
echo "=== Création des règles de pare-feu Partenaire ==="
gcloud compute firewall-rules create ${VPC_PARTNER}-allow-internal \
    --network=$VPC_PARTNER --allow=tcp,udp,icmp --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_PARTNER}-allow-ssh-iap \
    --network=$VPC_PARTNER --allow=tcp:22 --source-ranges=35.235.240.0/20

echo ""
echo "Architecture hybride créée avec succès !"
