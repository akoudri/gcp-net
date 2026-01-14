#!/bin/bash
# Lab 4.3 - Exercice 4.3.2 : Créer le peering Beta ↔ Gamma
# Objectif : Établir un peering entre Beta et Gamma

set -e

echo "=== Lab 4.3 - Exercice 2 : Créer le peering Beta ↔ Gamma ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_BETA="vpc-beta"
export VPC_GAMMA="vpc-gamma"

echo "Création du peering entre Beta et Gamma..."
echo ""

# Peering Beta → Gamma
echo "Création du peering de Beta vers Gamma..."
gcloud compute networks peerings create peering-beta-to-gamma \
    --network=$VPC_BETA \
    --peer-network=$VPC_GAMMA \
    --peer-project=$PROJECT_ID

echo ""

# Peering Gamma → Beta
echo "Création du peering de Gamma vers Beta..."
gcloud compute networks peerings create peering-gamma-to-beta \
    --network=$VPC_GAMMA \
    --peer-network=$VPC_BETA \
    --peer-project=$PROJECT_ID

echo ""
echo "Peering Beta ↔ Gamma créé avec succès !"
echo ""

# Attendre l'activation
echo "Attente de l'activation du peering..."
sleep 10

# Vérifier
echo "=== Peerings de VPC Beta ==="
gcloud compute networks peerings list --network=$VPC_BETA
echo ""

echo "=== Peerings de VPC Gamma ==="
gcloud compute networks peerings list --network=$VPC_GAMMA
echo ""

echo "Architecture actuelle :"
echo "Alpha ↔ Beta ↔ Gamma"
echo "Question : Alpha peut-il atteindre Gamma via Beta ?"
echo ""
