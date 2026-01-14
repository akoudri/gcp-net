#!/bin/bash
# Lab 5.6 - Exercice 5.6.1 : Créer le VPC Producteur
# Objectif : Créer l'infrastructure pour le producteur PSC

set -e

echo "=== Lab 5.6 - Exercice 1 : Créer le VPC Producteur ==="
echo ""

# VPC pour le producteur
export VPC_PRODUCER="vpc-producer"
export REGION="europe-west1"

echo "VPC : $VPC_PRODUCER"
echo "Région : $REGION"
echo ""

# Créer le VPC
echo "Création du VPC producteur..."
gcloud compute networks create $VPC_PRODUCER \
    --subnet-mode=custom \
    --description="VPC du producteur de service"

echo ""

# Sous-réseau pour les backends
echo "Création du sous-réseau pour les backends..."
gcloud compute networks subnets create subnet-producer \
    --network=$VPC_PRODUCER \
    --region=$REGION \
    --range=10.50.0.0/24

echo ""

# Sous-réseau spécial pour PSC NAT
echo "Création du sous-réseau PSC NAT..."
gcloud compute networks subnets create subnet-psc-nat \
    --network=$VPC_PRODUCER \
    --region=$REGION \
    --range=10.50.1.0/24 \
    --purpose=PRIVATE_SERVICE_CONNECT

echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."

echo "- Trafic interne..."
gcloud compute firewall-rules create ${VPC_PRODUCER}-allow-internal \
    --network=$VPC_PRODUCER \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

echo "- SSH via IAP..."
gcloud compute firewall-rules create ${VPC_PRODUCER}-allow-ssh-iap \
    --network=$VPC_PRODUCER \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo "- Health checks..."
gcloud compute firewall-rules create ${VPC_PRODUCER}-allow-health-check \
    --network=$VPC_PRODUCER \
    --allow=tcp:80 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --target-tags=backend

echo ""
echo "=== VPC Producteur créé ! ==="
echo ""
echo "Ressources créées :"
echo "- VPC: $VPC_PRODUCER"
echo "- Sous-réseau backend: subnet-producer (10.50.0.0/24)"
echo "- Sous-réseau PSC NAT: subnet-psc-nat (10.50.1.0/24)"
echo "- Règles de pare-feu: 3"
