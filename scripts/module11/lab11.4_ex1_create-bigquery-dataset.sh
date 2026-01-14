#!/bin/bash
# Lab 11.4 - Exercice 11.4.1 : Créer le dataset BigQuery
# Objectif : Créer un dataset BigQuery pour stocker les Flow Logs

set -e

echo "=== Lab 11.4 - Exercice 1 : Créer le dataset BigQuery ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Créer le dataset
echo "Création du dataset 'network_logs' dans BigQuery..."
bq mk --dataset --location=EU ${PROJECT_ID}:network_logs

echo ""
echo "Dataset créé avec succès !"
echo ""

# Vérifier
echo "=== Datasets disponibles ==="
bq ls

echo ""
echo "Le dataset 'network_logs' est prêt à recevoir les Flow Logs."
