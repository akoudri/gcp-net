#!/bin/bash
# Lab 6.7 - Exercice 6.7.5 : Créer une alerte sur les requêtes DNS suspectes
# Objectif : Créer des métriques et alertes pour surveiller le DNS

set -e

echo "=== Lab 6.7 - Exercice 5 : Créer une alerte sur les requêtes DNS ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Note: BigQuery dataset creation commented out as it requires additional setup
# echo "Création d'un sink vers BigQuery pour analyse avancée (optionnel)..."
# gcloud logging sinks create dns-logs-sink \
#     bigquery.googleapis.com/projects/$PROJECT_ID/datasets/dns_logs \
#     --log-filter='resource.type="dns_query"'
# echo ""

# Créer une métrique basée sur les logs
echo "Création d'une métrique pour compter les requêtes NXDOMAIN..."
gcloud logging metrics create dns-nxdomain-count \
    --description="Nombre de requêtes DNS avec NXDOMAIN" \
    --log-filter='resource.type="dns_query" AND jsonPayload.responseCode="NXDOMAIN"'
echo ""

echo "Métrique créée avec succès !"
echo ""

# Voir les métriques
echo "=== Détails de la métrique ==="
gcloud logging metrics describe dns-nxdomain-count
echo ""

echo "Cette métrique peut être utilisée dans Cloud Monitoring pour :"
echo "- Créer des dashboards"
echo "- Configurer des alertes"
echo "- Analyser les tendances DNS"
