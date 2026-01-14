#!/bin/bash
# Lab 7.8 - Exercice 7.8.2 : Créer le Hub NCC
# Objectif : Créer le hub Network Connectivity Center

set -e

echo "=== Lab 7.8 - Exercice 2 : Créer le Hub NCC ==="
echo ""

# Activer l'API Network Connectivity
echo ">>> Activation de l'API Network Connectivity..."
gcloud services enable networkconnectivity.googleapis.com

echo ""

# Créer le hub
echo ">>> Création du hub NCC..."
gcloud network-connectivity hubs create hub-multisite \
    --description="Hub central pour connectivité multi-sites"

echo ""

# Vérifier
echo "=== Hub NCC créé ==="
gcloud network-connectivity hubs describe hub-multisite

echo ""
echo "=== Hub créé avec succès ==="
