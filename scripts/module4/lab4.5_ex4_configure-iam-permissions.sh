#!/bin/bash
# Lab 4.5 - Exercice 4.5.4 : Configurer les permissions IAM
# Objectif : Donner les permissions sur les sous-réseaux

set -e

echo "=== Lab 4.5 - Exercice 4 : Configurer les permissions IAM ==="
echo ""

# Variables
export HOST_PROJECT="${HOST_PROJECT:-network-host-YYYYMMDD}"
export SERVICE_PROJECT_1="${SERVICE_PROJECT_1:-service-frontend-YYYYMMDD}"
export SERVICE_PROJECT_2="${SERVICE_PROJECT_2:-service-backend-YYYYMMDD}"

if [ "$HOST_PROJECT" = "network-host-YYYYMMDD" ]; then
    echo "❌ Veuillez définir les variables de projet"
    exit 1
fi

echo "Configuration des permissions IAM..."
echo ""

# Obtenir les service accounts des projets de service
echo "Récupération des service accounts..."
export SA_FRONTEND=$(gcloud projects describe $SERVICE_PROJECT_1 \
    --format="get(projectNumber)")@cloudservices.gserviceaccount.com
export SA_BACKEND=$(gcloud projects describe $SERVICE_PROJECT_2 \
    --format="get(projectNumber)")@cloudservices.gserviceaccount.com

echo "Service Account Frontend : $SA_FRONTEND"
echo "Service Account Backend : $SA_BACKEND"
echo ""

# Donner les permissions sur les sous-réseaux spécifiques
# Frontend → subnet-frontend uniquement
echo "Attribution des permissions pour Frontend sur subnet-frontend..."
gcloud compute networks subnets add-iam-policy-binding subnet-frontend \
    --project=$HOST_PROJECT \
    --region=europe-west1 \
    --member="serviceAccount:$SA_FRONTEND" \
    --role="roles/compute.networkUser"

echo ""

# Backend → subnet-backend uniquement
echo "Attribution des permissions pour Backend sur subnet-backend..."
gcloud compute networks subnets add-iam-policy-binding subnet-backend \
    --project=$HOST_PROJECT \
    --region=europe-west1 \
    --member="serviceAccount:$SA_BACKEND" \
    --role="roles/compute.networkUser"

echo ""
echo "Permissions IAM configurées avec succès !"
