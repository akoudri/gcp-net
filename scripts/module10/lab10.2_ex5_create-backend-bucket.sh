#!/bin/bash
# Lab 10.2 - Exercice 10.2.5 : Créer le bucket pour le contenu statique
# Objectif : Créer un bucket Cloud Storage pour le contenu statique

set -e

echo "=== Lab 10.2 - Exercice 5 : Créer le backend bucket ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"

echo "Projet : $PROJECT_ID"
echo ""

# Créer le bucket
echo "Création du bucket gs://${PROJECT_ID}-static-content..."
gsutil mb -l $REGION gs://${PROJECT_ID}-static-content

echo ""
echo "Ajout de contenu statique..."

# Ajouter du contenu
echo "body { font-family: Arial; }" | gsutil cp - gs://${PROJECT_ID}-static-content/style.css
echo "console.log('Hello');" | gsutil cp - gs://${PROJECT_ID}-static-content/app.js

echo ""
echo "Configuration des permissions publiques..."

# Rendre public
gsutil iam ch allUsers:objectViewer gs://${PROJECT_ID}-static-content

echo ""
echo "Création du backend bucket..."

# Créer le backend bucket
gcloud compute backend-buckets create bucket-static \
    --gcs-bucket-name=${PROJECT_ID}-static-content

echo ""
echo "Backend bucket créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "Bucket : gs://${PROJECT_ID}-static-content"
echo "Backend bucket : bucket-static"
echo "Fichiers :"
echo "  - style.css"
echo "  - app.js"
echo ""
echo "Testez l'accès :"
echo "  gsutil ls gs://${PROJECT_ID}-static-content/"
