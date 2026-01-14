#!/bin/bash
# Lab 3.5 - Exercice 3.5.4 : Tester la connectivité APRÈS Cloud NAT
# Objectif : Vérifier que Cloud NAT permet l'accès Internet

set -e

echo "=== Lab 3.5 - Exercice 4 : Tester la connectivité APRÈS Cloud NAT ==="
echo ""

export REGION_EU="europe-west1"

echo "Reconnectez-vous à vm-nat-test :"
echo ""
echo "  gcloud compute ssh vm-nat-test --zone=${REGION_EU}-b --tunnel-through-iap"
echo ""
echo "Puis testez l'accès Internet (devrait fonctionner maintenant) :"
echo ""
echo "  # Tester l'accès Internet (devrait fonctionner)"
echo "  curl -s https://api.ipify.org && echo \" - Mon IP publique (NAT)\""
echo ""
echo "  # L'IP affichée est l'IP NAT, pas une IP de la VM"
echo ""
echo "  # Tester d'autres destinations"
echo "  curl -s --head https://www.google.com | head -5"
echo "  curl -s --head https://github.com | head -5"
echo ""
echo "  # Télécharger un package (preuve d'accès Internet)"
echo "  sudo apt-get update"
echo "  sudo apt-get install -y htop"
echo ""
echo "  exit"
echo ""
echo "Questions à considérer :"
echo "1. L'IP publique vue par les serveurs externes est-elle l'IP de la VM ?"
echo "2. Plusieurs VMs partagent-elles la même IP NAT ?"
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
