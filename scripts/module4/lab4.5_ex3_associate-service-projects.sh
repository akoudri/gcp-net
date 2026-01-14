#!/bin/bash
# Lab 4.5 - Exercice 4.5.3 : Associer les projets de service
# Objectif : Lier les projets de service au projet hôte

set -e

echo "=== Lab 4.5 - Exercice 3 : Associer les projets de service ==="
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
echo "Projet service 1 : $SERVICE_PROJECT_1"
echo "Projet service 2 : $SERVICE_PROJECT_2"
echo ""

# Associer le projet frontend
echo "Association du projet frontend..."
gcloud compute shared-vpc associated-projects add $SERVICE_PROJECT_1 \
    --host-project=$HOST_PROJECT

echo ""

# Associer le projet backend
echo "Association du projet backend..."
gcloud compute shared-vpc associated-projects add $SERVICE_PROJECT_2 \
    --host-project=$HOST_PROJECT

echo ""
echo "Projets associés avec succès !"
echo ""

# Vérifier les associations
echo "=== Projets de service associés ==="
gcloud compute shared-vpc list-associated-resources $HOST_PROJECT

echo ""
