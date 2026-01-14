#!/bin/bash
# Lab 9.2 - Exercice 9.2.1 : Créer l'infrastructure de base
# Objectif : Créer le VPC et les règles de pare-feu pour Cloud Armor

set -e

echo "=== Lab 9.2 - Exercice 1 : Créer l'infrastructure de base ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# Créer le VPC
echo "Création du VPC vpc-armor-lab..."
gcloud compute networks create vpc-armor-lab \
    --subnet-mode=custom

echo ""
echo "Création du sous-réseau subnet-web..."
gcloud compute networks subnets create subnet-web \
    --network=vpc-armor-lab \
    --region=$REGION \
    --range=10.0.1.0/24

echo ""
echo "=== Création des règles de pare-feu ==="

# Autoriser les health checks Google
echo "Création de la règle pour les health checks..."
gcloud compute firewall-rules create vpc-armor-lab-allow-health-check \
    --network=vpc-armor-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80,tcp:443,tcp:8080 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --target-tags=web-server

# Autoriser le trafic du Load Balancer
echo "Création de la règle pour le Load Balancer..."
gcloud compute firewall-rules create vpc-armor-lab-allow-lb \
    --network=vpc-armor-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# Autoriser SSH via IAP
echo "Création de la règle pour SSH via IAP..."
gcloud compute firewall-rules create vpc-armor-lab-allow-iap \
    --network=vpc-armor-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20

echo ""
echo "Infrastructure de base créée avec succès !"
echo ""

# Vérifier
echo "=== VPC créé ==="
gcloud compute networks describe vpc-armor-lab
echo ""

echo "=== Sous-réseaux ==="
gcloud compute networks subnets list --network=vpc-armor-lab
echo ""

echo "=== Règles de pare-feu ==="
gcloud compute firewall-rules list --filter="network:vpc-armor-lab"
