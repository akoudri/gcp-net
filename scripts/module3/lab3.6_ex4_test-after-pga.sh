#!/bin/bash
# Lab 3.6 - Exercice 3.6.4 : Tester APRÈS Private Google Access
# Objectif : Vérifier que PGA permet l'accès aux APIs Google

set -e

echo "=== Lab 3.6 - Exercice 4 : Tester APRÈS Private Google Access ==="
echo ""

export REGION_EU="europe-west1"

echo "Reconnectez-vous à vm-isolated :"
echo ""
echo "  gcloud compute ssh vm-isolated --zone=${REGION_EU}-b --tunnel-through-iap"
echo ""
echo "Puis testez l'accès (devrait fonctionner maintenant pour les APIs Google) :"
echo ""
echo "  # Tester l'accès à Cloud Storage (devrait fonctionner maintenant)"
echo "  gsutil ls gs://gcp-public-data-landsat | head -5"
echo "  # Liste des fichiers du bucket public"
echo ""
echo "  # Tester l'accès à Internet (toujours impossible - PGA ≠ NAT)"
echo "  curl -s --connect-timeout 5 https://www.github.com"
echo "  # Timeout attendu - PGA ne donne pas accès à Internet"
echo ""
echo "  # Tester l'accès à une API Google"
echo "  curl -s -H \"Metadata-Flavor: Google\" \\"
echo "      \"http://metadata.google.internal/computeMetadata/v1/project/project-id\""
echo ""
echo "  exit"
echo ""
echo "Questions à considérer :"
echo "1. Private Google Access permet-il d'accéder à github.com ?"
echo "2. Peut-on combiner Cloud NAT et Private Google Access ?"
echo "3. PGA utilise-t-il la route par défaut (0.0.0.0/0) ?"
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
