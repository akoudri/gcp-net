#!/bin/bash
# Lab 10.9 - Exercice 10.9.2 : Créer un Serverless NEG (Cloud Run)
# Objectif : Créer un NEG pour Cloud Run et l'intégrer au Load Balancer

set -e

echo "=== Lab 10.9 - Exercice 2 : Créer un Serverless NEG ==="
echo ""

# Variables
export REGION="europe-west1"

# Déployer un service Cloud Run simple
echo "Déploiement d'un service Cloud Run..."
gcloud run deploy hello-service \
    --image=gcr.io/cloudrun/hello \
    --platform=managed \
    --region=$REGION \
    --allow-unauthenticated

echo ""
echo "Création du Serverless NEG..."

# Créer le Serverless NEG
gcloud compute network-endpoint-groups create neg-cloudrun \
    --region=$REGION \
    --network-endpoint-type=SERVERLESS \
    --cloud-run-service=hello-service

echo ""
echo "Création du backend service pour Cloud Run..."

# Créer un backend service pour le NEG serverless
gcloud compute backend-services create backend-cloudrun \
    --global

echo ""
echo "Ajout du NEG au backend service..."

gcloud compute backend-services add-backend backend-cloudrun \
    --network-endpoint-group=neg-cloudrun \
    --network-endpoint-group-region=$REGION \
    --global

echo ""
echo "Ajout au URL Map..."

# Ajouter au URL Map
gcloud compute url-maps add-path-matcher urlmap-app \
    --path-matcher-name=serverless \
    --default-service=backend-cloudrun \
    --path-rules="/run/*=backend-cloudrun"

echo ""
echo "Serverless NEG créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "Cloud Run Service : hello-service"
echo "NEG : neg-cloudrun"
echo "Backend Service : backend-cloudrun"
echo "Route : /run/* → backend-cloudrun"
echo ""
echo "Testez :"
echo "  curl http://\$LB_IP/run/"
