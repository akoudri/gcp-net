#!/bin/bash
# Lab 5.7 - Exercice 5.7.1 : Créer le VPC Consommateur
# Objectif : Créer l'infrastructure pour le consommateur PSC

set -e

echo "=== Lab 5.7 - Exercice 1 : Créer le VPC Consommateur ==="
echo ""

# VPC pour le consommateur
export VPC_CONSUMER="vpc-consumer"
export REGION="europe-west1"

echo "VPC : $VPC_CONSUMER"
echo "Région : $REGION"
echo ""

# Créer le VPC
echo "Création du VPC consommateur..."
gcloud compute networks create $VPC_CONSUMER \
    --subnet-mode=custom \
    --description="VPC du consommateur de service"

echo ""

# Sous-réseau
echo "Création du sous-réseau..."
gcloud compute networks subnets create subnet-consumer \
    --network=$VPC_CONSUMER \
    --region=$REGION \
    --range=10.60.0.0/24

echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."

echo "- Trafic interne..."
gcloud compute firewall-rules create ${VPC_CONSUMER}-allow-internal \
    --network=$VPC_CONSUMER \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

echo "- SSH via IAP..."
gcloud compute firewall-rules create ${VPC_CONSUMER}-allow-ssh-iap \
    --network=$VPC_CONSUMER \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo ""
echo "=== VPC Consommateur créé ! ==="
echo ""
echo "Ressources créées :"
echo "- VPC: $VPC_CONSUMER"
echo "- Sous-réseau: subnet-consumer (10.60.0.0/24)"
echo "- Règles de pare-feu: 2"
