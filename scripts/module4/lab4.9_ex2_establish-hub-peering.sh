#!/bin/bash
# Lab 4.9 - Exercice 4.9.2 : Établir le peering Hub ↔ Partenaire
# Objectif : Créer le peering entre le hub interne et l'organisation partenaire

set -e

echo "=== Lab 4.9 - Exercice 2 : Établir le peering Hub ↔ Partenaire ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_HUB="vpc-hub"
export VPC_PARTNER="vpc-partner"

echo "Projet : $PROJECT_ID"
echo "Configuration du peering entre Hub et Partenaire..."
echo ""

# Peering bidirectionnel
echo "Création du peering Hub → Partenaire..."
gcloud compute networks peerings create peering-hub-to-partner \
    --network=$VPC_HUB \
    --peer-network=$VPC_PARTNER \
    --peer-project=$PROJECT_ID \
    --export-custom-routes

echo ""

echo "Création du peering Partenaire → Hub..."
gcloud compute networks peerings create peering-partner-to-hub \
    --network=$VPC_PARTNER \
    --peer-network=$VPC_HUB \
    --peer-project=$PROJECT_ID \
    --import-custom-routes

echo ""
echo "Peering Hub ↔ Partenaire établi !"
echo ""

# Attendre l'activation
echo "Attente de l'activation du peering..."
sleep 10

# Vérifier
echo "=== Peerings du Hub ==="
gcloud compute networks peerings list --network=$VPC_HUB
echo ""

echo "=== Peerings du Partenaire ==="
gcloud compute networks peerings list --network=$VPC_PARTNER
