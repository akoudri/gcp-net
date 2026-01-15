#!/bin/bash
# Lab 10.2 - Exercice 10.2.1 : Créer l'infrastructure de base
# Objectif : Créer le VPC et les règles de pare-feu pour le Load Balancer

set -e

echo "=== Lab 10.2 - Exercice 1 : Créer l'infrastructure de base ==="
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
echo "Création du VPC vpc-lb-lab..."
gcloud compute networks create vpc-lb-lab \
    --subnet-mode=custom 2>/dev/null || echo "VPC vpc-lb-lab existe déjà"

echo ""
echo "Création du sous-réseau subnet-web..."
gcloud compute networks subnets create subnet-web \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.1.0/24 2>/dev/null || echo "Sous-réseau subnet-web existe déjà"

echo ""
echo "Création des règles de pare-feu..."

# Règle pour les health checks
gcloud compute firewall-rules create vpc-lb-lab-allow-health-check \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80,tcp:8080 \
    --source-ranges=35.191.0.0/16,130.211.0.0/22 \
    --target-tags=web-server 2>/dev/null || echo "Règle vpc-lb-lab-allow-health-check existe déjà"

# Règle pour IAP
gcloud compute firewall-rules create vpc-lb-lab-allow-iap \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 2>/dev/null || echo "Règle vpc-lb-lab-allow-iap existe déjà"

echo ""
echo "Infrastructure de base créée avec succès !"
echo ""
echo "=== Résumé ==="
echo "VPC : vpc-lb-lab"
echo "Sous-réseau : subnet-web (10.0.1.0/24)"
echo "Règles de pare-feu : vpc-lb-lab-allow-health-check, vpc-lb-lab-allow-iap"
