#!/bin/bash
# Lab 4.5 - Exercice 4.5.2 : Configurer le projet hôte
# Objectif : Activer Shared VPC et créer le VPC partagé
# ⚠️ Nécessite le rôle compute.xpnAdmin

set -e

echo "=== Lab 4.5 - Exercice 2 : Configurer le projet hôte ==="
echo ""

# Variables
export HOST_PROJECT="${HOST_PROJECT:-network-host-YYYYMMDD}"
export ORG_ID="${ORG_ID:-YOUR_ORG_ID}"

if [ "$HOST_PROJECT" = "network-host-YYYYMMDD" ]; then
    echo "❌ Veuillez définir la variable HOST_PROJECT"
    echo "   Utilisez les valeurs de l'exercice précédent"
    exit 1
fi

echo "Projet hôte : $HOST_PROJECT"
echo ""

# Activer Shared VPC sur le projet hôte
echo "Activation de Shared VPC sur le projet hôte..."
gcloud compute shared-vpc enable $HOST_PROJECT

echo ""

# Vérifier l'activation
echo "=== Vérification de l'activation ==="
gcloud compute shared-vpc organizations list-host-projects \
    --organization=$ORG_ID 2>/dev/null || echo "Vérifiez vos permissions"

echo ""

# Créer le VPC partagé dans le projet hôte
echo "Création du VPC partagé..."
gcloud compute networks create shared-vpc \
    --project=$HOST_PROJECT \
    --subnet-mode=custom

echo ""

# Créer les sous-réseaux
echo "Création du sous-réseau frontend..."
gcloud compute networks subnets create subnet-frontend \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --region=europe-west1 \
    --range=10.100.0.0/24 \
    --enable-private-ip-google-access

echo ""

echo "Création du sous-réseau backend..."
gcloud compute networks subnets create subnet-backend \
    --project=$HOST_PROJECT \
    --network=shared-vpc \
    --region=europe-west1 \
    --range=10.100.1.0/24 \
    --enable-private-ip-google-access

echo ""
echo "Configuration du projet hôte terminée !"
