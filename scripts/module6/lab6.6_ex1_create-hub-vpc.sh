#!/bin/bash
# Lab 6.6 - Exercice 6.6.1 : Créer le VPC Hub
# Objectif : Créer un VPC Hub avec DNS centralisé

set -e

echo "=== Lab 6.6 - Exercice 1 : Créer le VPC Hub ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# VPC Hub (services centralisés)
echo "Création du VPC Hub..."
gcloud compute networks create vpc-hub \
    --subnet-mode=custom \
    --description="VPC Hub avec DNS centralisé"
echo ""

echo "Création du sous-réseau Hub..."
gcloud compute networks subnets create subnet-hub \
    --network=vpc-hub \
    --region=$REGION \
    --range=10.10.0.0/24
echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."
gcloud compute firewall-rules create vpc-hub-allow-internal \
    --network=vpc-hub \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8
echo ""

gcloud compute firewall-rules create vpc-hub-allow-ssh-iap \
    --network=vpc-hub \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20
echo ""

echo "VPC Hub créé avec succès !"
echo ""

echo "=== Vérification ==="
gcloud compute networks describe vpc-hub
