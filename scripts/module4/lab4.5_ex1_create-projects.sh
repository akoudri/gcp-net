#!/bin/bash
# Lab 4.5 - Exercice 4.5.1 : Créer les projets (si nécessaire)
# Objectif : Créer le projet hôte et les projets de service
# ⚠️ Nécessite une organisation GCP et les permissions appropriées

set -e

echo "=== Lab 4.5 - Exercice 1 : Créer les projets ==="
echo ""
echo "⚠️  Ce script nécessite :"
echo "   - Une organisation GCP"
echo "   - Le rôle resourcemanager.projectCreator"
echo "   - Un compte de facturation"
echo ""

# Variables à configurer
export ORG_ID="${ORG_ID:-YOUR_ORG_ID}"
export BILLING_ACCOUNT="${BILLING_ACCOUNT:-YOUR_BILLING_ACCOUNT}"
export HOST_PROJECT="network-host-$(date +%Y%m%d)"
export SERVICE_PROJECT_1="service-frontend-$(date +%Y%m%d)"
export SERVICE_PROJECT_2="service-backend-$(date +%Y%m%d)"

if [ "$ORG_ID" = "YOUR_ORG_ID" ]; then
    echo "❌ Veuillez définir les variables d'environnement :"
    echo "   export ORG_ID='your-org-id'"
    echo "   export BILLING_ACCOUNT='your-billing-account'"
    exit 1
fi

echo "Organisation ID : $ORG_ID"
echo "Compte de facturation : $BILLING_ACCOUNT"
echo "Projet hôte : $HOST_PROJECT"
echo "Projet service 1 : $SERVICE_PROJECT_1"
echo "Projet service 2 : $SERVICE_PROJECT_2"
echo ""

# Créer le projet hôte
echo "Création du projet hôte..."
gcloud projects create $HOST_PROJECT \
    --organization=$ORG_ID \
    --name="Network Host Project"

gcloud billing projects link $HOST_PROJECT \
    --billing-account=$BILLING_ACCOUNT

echo ""

# Créer les projets de service
echo "Création du projet de service Frontend..."
gcloud projects create $SERVICE_PROJECT_1 \
    --organization=$ORG_ID \
    --name="Service Frontend"

gcloud billing projects link $SERVICE_PROJECT_1 \
    --billing-account=$BILLING_ACCOUNT

echo ""

echo "Création du projet de service Backend..."
gcloud projects create $SERVICE_PROJECT_2 \
    --organization=$ORG_ID \
    --name="Service Backend"

gcloud billing projects link $SERVICE_PROJECT_2 \
    --billing-account=$BILLING_ACCOUNT

echo ""

# Activer les APIs nécessaires
echo "Activation des APIs Compute..."
for PROJECT in $HOST_PROJECT $SERVICE_PROJECT_1 $SERVICE_PROJECT_2; do
    echo "  - $PROJECT"
    gcloud services enable compute.googleapis.com --project=$PROJECT
done

echo ""
echo "Projets créés avec succès !"
echo ""
echo "Sauvegardez ces valeurs pour les exercices suivants :"
echo "export HOST_PROJECT=$HOST_PROJECT"
echo "export SERVICE_PROJECT_1=$SERVICE_PROJECT_1"
echo "export SERVICE_PROJECT_2=$SERVICE_PROJECT_2"
