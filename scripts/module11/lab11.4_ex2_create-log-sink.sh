#!/bin/bash
# Lab 11.4 - Exercice 11.4.2 : Créer le sink de logs
# Objectif : Configurer l'export des Flow Logs vers BigQuery

set -e

echo "=== Lab 11.4 - Exercice 2 : Créer le sink de logs ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Créer le sink vers BigQuery
echo "Création du sink 'flow-logs-to-bq'..."
gcloud logging sinks create flow-logs-to-bq \
    bigquery.googleapis.com/projects/${PROJECT_ID}/datasets/network_logs \
    --log-filter='resource.type="gce_subnetwork"'

echo ""
echo "Sink créé avec succès !"
echo ""

# Récupérer le service account du sink
echo "Récupération du service account du sink..."
SINK_SA=$(gcloud logging sinks describe flow-logs-to-bq --format="get(writerIdentity)")
echo "Service Account du sink : $SINK_SA"
echo ""

# Donner les droits au service account sur le dataset
echo "Attribution des droits BigQuery au service account..."
bq add-iam-policy-binding \
    --member="$SINK_SA" \
    --role="roles/bigquery.dataEditor" \
    ${PROJECT_ID}:network_logs

echo ""
echo "=== Configuration terminée ==="
echo ""
echo "Les Flow Logs seront maintenant exportés vers BigQuery."
echo "Note: Il peut y avoir un délai de quelques minutes avant que les données n'apparaissent."
