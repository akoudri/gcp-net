#!/bin/bash
# Lab 3.2 - Exercice 3.2.1 : Configurer les règles de pare-feu
# Objectif : Préparer les règles de pare-feu pour les tests de routage

set -e

echo "=== Lab 3.2 - Exercice 1 : Configurer les règles de pare-feu ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Règles de pare-feu
echo "Création de la règle allow-internal..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

echo ""
echo "Création de la règle allow-ssh-iap..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

echo ""
echo "Règles de pare-feu créées avec succès !"
echo ""

echo "=== Règles créées ==="
gcloud compute firewall-rules list --filter="network=$VPC_NAME"
echo ""
