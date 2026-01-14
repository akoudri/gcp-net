#!/bin/bash
# Lab 3.7 - Exercice 3.7.3 : Tester la résolution DNS
# Objectif : Vérifier la résolution DNS depuis les VMs

set -e

echo "=== Lab 3.7 - Exercice 3 : Tester la résolution DNS ==="
echo ""

export REGION_EU="europe-west1"

echo "Connectez-vous à une VM du VPC :"
echo ""
echo "  gcloud compute ssh vm-eu --zone=${REGION_EU}-b --tunnel-through-iap"
echo ""
echo "Puis testez la résolution des noms créés :"
echo ""
echo "  # Tester la résolution avec dig"
echo "  dig vm-eu.internal.lab +short"
echo "  dig vm-us.internal.lab +short"
echo "  dig database.internal.lab +short"
echo ""
echo "  # Tester avec nslookup"
echo "  nslookup vm-eu.internal.lab"
echo ""
echo "  # Ping en utilisant le nom DNS"
echo "  ping -c 3 vm-us.internal.lab"
echo ""
echo "  exit"
echo ""
echo "Questions à considérer :"
echo "1. La zone privée est-elle accessible depuis Internet ?"
echo "2. Quel serveur DNS résout ces requêtes ?"
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
