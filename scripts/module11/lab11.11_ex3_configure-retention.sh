#!/bin/bash
# Lab 11.11 - Exercice 11.11.3 : Configurer la rétention
# Objectif : Optimiser la rétention des logs pour réduire les coûts

set -e

echo "=== Lab 11.11 - Exercice 3 : Configurer la rétention ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"

echo "Projet : $PROJECT_ID"
echo ""

# Configurer la rétention du bucket de logs par défaut
echo "1. Configuration de la rétention à 30 jours dans Cloud Logging..."
gcloud logging buckets update _Default \
    --location=global \
    --retention-days=30

echo ""
echo "Rétention configurée : 30 jours dans Cloud Logging"
echo ""

# Créer un bucket Cloud Storage pour l'archivage
echo "2. Création d'un bucket Cloud Storage pour l'archivage long terme..."
gsutil mb -l $REGION gs://${PROJECT_ID}-logs-archive 2>/dev/null || echo "Bucket déjà existant"

echo ""
echo "Bucket Cloud Storage créé : gs://${PROJECT_ID}-logs-archive"
echo ""

echo "Note: Pour créer un sink d'archivage, vous pouvez utiliser la commande suivante"
echo "après avoir modifié le filtre de timestamp :"
echo ""
echo "gcloud logging sinks create archive-old-logs \\"
echo "    storage.googleapis.com/${PROJECT_ID}-logs-archive \\"
echo "    --log-filter='resource.type=\"gce_subnetwork\" timestamp<\"TIMESTAMP_30_DAYS_AGO\"'"
echo ""
echo "=== Configuration de rétention terminée ==="
echo ""
echo "Stratégie de rétention recommandée :"
echo "  - 30 jours dans Cloud Logging (recherche rapide)"
echo "  - Archive long terme dans Cloud Storage (coût réduit)"
echo "  - Analyse avec BigQuery pour les requêtes complexes"
