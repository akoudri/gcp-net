#!/bin/bash
# Lab 5.3 - Exercice 5.3.1 : Activer l'API Service Networking
# Objectif : Activer les APIs nécessaires pour Private Services Access

set -e

echo "=== Lab 5.3 - Exercice 1 : Activer l'API Service Networking ==="
echo ""

# Activer l'API nécessaire pour PSA
echo "Activation de l'API Service Networking..."
gcloud services enable servicenetworking.googleapis.com

echo ""
echo "API activée avec succès !"
echo ""

# Vérifier l'activation
echo "=== Vérification de l'API ==="
gcloud services list --filter="name:servicenetworking" --format="table(name,state)"

echo ""
echo "=== API Service Networking activée ! ==="
echo ""
echo "Cette API est nécessaire pour :"
echo "- Private Services Access (PSA)"
echo "- Connexion VPC Peering avec les services managés Google"
echo "- Cloud SQL, Memorystore, etc."
