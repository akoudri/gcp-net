#!/bin/bash
# Lab 9.3 - Exercice 9.3.1 : Créer la politique de sécurité
# Objectif : Créer une politique de sécurité Cloud Armor de base

set -e

echo "=== Lab 9.3 - Exercice 1 : Créer la politique de sécurité ==="
echo ""

# Créer la politique
echo "Création de la politique Cloud Armor..."
gcloud compute security-policies create policy-web-app \
    --description="Politique de sécurité pour l'application web"

echo ""
echo "Politique créée avec succès !"
echo ""

# Vérifier la création
echo "=== Détails de la politique ==="
gcloud compute security-policies describe policy-web-app

echo ""
echo "=== Règles de la politique ==="
gcloud compute security-policies rules list --security-policy=policy-web-app

echo ""
echo "REMARQUE : La politique a une règle par défaut (priority=2147483647) qui autorise tout le trafic."
