#!/bin/bash
# Lab 3.6 - Exercice 3.6.2 : Tester AVANT Private Google Access
# Objectif : Constater l'absence d'accès aux APIs Google sans PGA

set -e

echo "=== Lab 3.6 - Exercice 2 : Tester AVANT Private Google Access ==="
echo ""

export REGION_EU="europe-west1"

echo "Connectez-vous à vm-isolated :"
echo ""
echo "  gcloud compute ssh vm-isolated --zone=${REGION_EU}-b --tunnel-through-iap"
echo ""
echo "Puis testez l'accès (devrait échouer) :"
echo ""
echo "  # Tester l'accès à Cloud Storage (devrait échouer)"
echo "  gsutil ls gs://gcp-public-data-landsat"
echo "  # Erreur de connexion attendue"
echo ""
echo "  # Tester l'accès à Internet (devrait échouer)"
echo "  curl -s --connect-timeout 5 https://www.google.com"
echo "  # Timeout attendu"
echo ""
echo "  exit"
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
