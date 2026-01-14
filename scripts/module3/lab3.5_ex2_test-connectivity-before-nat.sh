#!/bin/bash
# Lab 3.5 - Exercice 3.5.2 : Tester la connectivité AVANT Cloud NAT
# Objectif : Constater l'absence d'accès Internet sans Cloud NAT

set -e

echo "=== Lab 3.5 - Exercice 2 : Tester la connectivité AVANT Cloud NAT ==="
echo ""

export REGION_EU="europe-west1"

echo "Connectez-vous à vm-nat-test via IAP :"
echo ""
echo "  gcloud compute ssh vm-nat-test --zone=${REGION_EU}-b --tunnel-through-iap"
echo ""
echo "Puis testez l'accès Internet (devrait échouer) :"
echo ""
echo "  # Tester l'accès Internet (timeout attendu)"
echo "  curl -s --connect-timeout 5 https://api.ipify.org && echo \" - Mon IP publique\""
echo ""
echo "  # Tester la résolution DNS (peut fonctionner via le metadata server)"
echo "  dig google.com +short"
echo ""
echo "  # Tester l'accès aux APIs Google (échoue sans PGA)"
echo "  curl -s --connect-timeout 5 https://storage.googleapis.com"
echo ""
echo "  exit"
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
