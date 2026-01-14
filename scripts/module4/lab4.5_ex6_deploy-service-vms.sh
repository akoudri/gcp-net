#!/bin/bash
# Lab 4.5 - Exercice 4.5.6 : Déployer des ressources dans les projets de service
# Objectif : Créer des VMs dans les projets de service utilisant le réseau partagé

set -e

echo "=== Lab 4.5 - Exercice 6 : Déployer des ressources dans les projets de service ==="
echo ""

# Variables
export HOST_PROJECT="${HOST_PROJECT:-network-host-YYYYMMDD}"
export SERVICE_PROJECT_1="${SERVICE_PROJECT_1:-service-frontend-YYYYMMDD}"
export SERVICE_PROJECT_2="${SERVICE_PROJECT_2:-service-backend-YYYYMMDD}"

if [ "$HOST_PROJECT" = "network-host-YYYYMMDD" ]; then
    echo "❌ Veuillez définir les variables de projet"
    exit 1
fi

echo "Projet hôte : $HOST_PROJECT"
echo "Projet service Frontend : $SERVICE_PROJECT_1"
echo "Projet service Backend : $SERVICE_PROJECT_2"
echo ""

# VM dans le projet frontend (utilisant le sous-réseau partagé)
echo "Création de la VM frontend..."
gcloud compute instances create vm-frontend \
    --project=$SERVICE_PROJECT_1 \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --subnet=projects/$HOST_PROJECT/regions/europe-west1/subnetworks/subnet-frontend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""

# VM dans le projet backend
echo "Création de la VM backend..."
gcloud compute instances create vm-backend \
    --project=$SERVICE_PROJECT_2 \
    --zone=europe-west1-b \
    --machine-type=e2-micro \
    --subnet=projects/$HOST_PROJECT/regions/europe-west1/subnetworks/subnet-backend \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "VMs déployées avec succès dans les projets de service !"
echo ""

echo "Note : Les VMs utilisent les sous-réseaux du projet hôte"
echo "mais sont créées dans leurs projets de service respectifs."
