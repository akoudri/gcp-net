#!/bin/bash
# Lab 5.4 - Exercice 5.4.1 : Activer l'API Memorystore
# Objectif : Activer les APIs nécessaires pour Memorystore Redis

set -e

echo "=== Lab 5.4 - Exercice 1 : Activer l'API Memorystore ==="
echo ""

# Activer l'API Redis
echo "Activation de l'API Memorystore Redis..."
gcloud services enable redis.googleapis.com

echo ""
echo "API activée avec succès !"
echo ""

# Vérifier
echo "=== Vérification de l'API ==="
gcloud services list --filter="name:redis" --format="table(name,state)"

echo ""
echo "=== API Memorystore Redis activée ! ==="
echo ""
echo "Vous pouvez maintenant créer des instances Memorystore Redis."
