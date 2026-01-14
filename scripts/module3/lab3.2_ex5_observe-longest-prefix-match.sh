#!/bin/bash
# Lab 3.2 - Exercice 3.2.5 : Observer le longest prefix match
# Objectif : Comprendre le longest prefix match en action

set -e

echo "=== Lab 3.2 - Exercice 5 : Observer le longest prefix match ==="
echo ""

export REGION_US="us-central1"

echo "Pour tester le longest prefix match, connectez-vous à vm-us :"
echo ""
echo "  gcloud compute ssh vm-us --zone=${REGION_US}-a --tunnel-through-iap"
echo ""
echo "Puis exécutez les commandes suivantes :"
echo ""
echo "  # Vers 10.99.0.50 - devrait utiliser route-specific (/24)"
echo "  traceroute -n 10.99.0.50"
echo ""
echo "  # Vers 10.99.1.50 - devrait utiliser route-broad (/16)"
echo "  traceroute -n 10.99.1.50"
echo ""
echo "Ces IPs n'existent pas, mais on observe quelle route serait utilisée."
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
