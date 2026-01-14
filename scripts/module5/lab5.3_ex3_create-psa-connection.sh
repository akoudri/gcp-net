#!/bin/bash
# Lab 5.3 - Exercice 5.3.3 : Créer la connexion Private Services Access
# Objectif : Établir la connexion VPC Peering avec Google

set -e

echo "=== Lab 5.3 - Exercice 3 : Créer la connexion PSA ==="
echo ""

export VPC_NAME="vpc-private-access"

echo "VPC : $VPC_NAME"
echo ""

# Créer la connexion de service privé
echo "Création de la connexion Private Services Access..."
echo "Cette opération peut prendre quelques minutes..."
gcloud services vpc-peerings connect \
    --service=servicenetworking.googleapis.com \
    --ranges=google-managed-services \
    --network=$VPC_NAME

echo ""
echo "Connexion PSA créée avec succès !"
echo ""
echo "Un VPC Peering a été automatiquement créé avec le VPC de Google."
echo "Attendre quelques secondes pour l'établissement complet..."
sleep 10

# Vérifier la connexion
echo ""
echo "=== Connexions VPC Peering pour les services ==="
gcloud services vpc-peerings list --network=$VPC_NAME

echo ""

# Voir le peering créé
echo "=== VPC Peerings dans le réseau ==="
gcloud compute networks peerings list --network=$VPC_NAME --format="table(name,network,peerNetwork,state,stateDetails)"

echo ""
echo "=== Connexion PSA établie ! ==="
echo ""
echo "Les services managés Google (Cloud SQL, Memorystore, etc.)"
echo "peuvent maintenant être déployés avec des IPs privées dans votre VPC."
