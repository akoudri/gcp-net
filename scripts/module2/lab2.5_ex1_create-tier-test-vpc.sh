#!/bin/bash
# Lab 2.5 - Exercice 2.5.1 : Créer un VPC de test pour Network Tiers
# Objectif : Préparer l'infrastructure pour comparer les Network Tiers

set -e

echo "=== Lab 2.5 - Exercice 1 : Créer un VPC de test ==="
echo ""

# VPC pour les tests de Network Tiers
echo "Création du VPC tier-test-vpc..."
gcloud compute networks create tier-test-vpc \
    --subnet-mode=custom

gcloud compute networks subnets create tier-test-subnet \
    --network=tier-test-vpc \
    --region=europe-west1 \
    --range=10.100.0.0/24

echo ""

# Règle pare-feu pour SSH et ICMP
echo "Configuration des règles de pare-feu..."
gcloud compute firewall-rules create tier-test-allow-all \
    --network=tier-test-vpc \
    --allow=tcp:22,icmp \
    --source-ranges=0.0.0.0/0

echo ""
echo "VPC de test créé avec succès !"
