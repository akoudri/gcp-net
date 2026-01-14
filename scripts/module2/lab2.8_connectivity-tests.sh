#!/bin/bash
# Lab 2.8 - Exercice 2.8.1 : Utiliser Connectivity Tests
# Objectif : Diagnostiquer la connectivité avec les outils GCP

set -e

echo "=== Lab 2.8 - Exercice 1 : Connectivity Tests ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)
export ZONE="europe-west1-b"

# Créer un test de connectivité
echo "Création d'un test de connectivité web-prod → api-prod..."
gcloud network-management connectivity-tests create test-web-to-api \
    --source-instance=projects/$PROJECT_ID/zones/$ZONE/instances/web-prod \
    --destination-instance=projects/$PROJECT_ID/zones/$ZONE/instances/api-prod \
    --destination-port=8080 \
    --protocol=TCP

echo ""
echo "Test créé. Attendez quelques secondes pour l'exécution..."
sleep 10

echo ""
echo "=== Résultat du test ==="
gcloud network-management connectivity-tests describe test-web-to-api

echo ""
echo "Le test indiquera si la connexion est possible et identifiera"
echo "les problèmes éventuels (règles de pare-feu, routes, etc.)"
