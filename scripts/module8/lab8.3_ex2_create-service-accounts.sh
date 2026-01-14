#!/bin/bash
# Lab 8.3 - Exercice 8.3.2 : Créer les Service Accounts
# Objectif : Créer des Service Accounts pour chaque tier

set -e

echo "=== Lab 8.3 - Exercice 2 : Créer les Service Accounts ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Créer les Service Accounts
echo ">>> Création du Service Account pour le tier Web..."
gcloud iam service-accounts create sa-web \
    --display-name="Service Account - Web Tier"

echo ""

echo ">>> Création du Service Account pour le tier API..."
gcloud iam service-accounts create sa-api \
    --display-name="Service Account - API Tier"

echo ""

echo ">>> Création du Service Account pour le tier Database..."
gcloud iam service-accounts create sa-db \
    --display-name="Service Account - Database Tier"

echo ""
echo "Service Accounts créés avec succès !"
echo ""

# Lister les SA créés
echo "=== Service Accounts créés ==="
gcloud iam service-accounts list \
    --format="table(email,displayName)"

echo ""
echo "Questions à considérer :"
echo "1. Quel est l'avantage d'utiliser un Service Account par tier ?"
echo "2. Comment les Service Accounts améliorent-ils la sécurité par rapport aux tags ?"
echo "3. Quelles permissions par défaut ont ces Service Accounts ?"
