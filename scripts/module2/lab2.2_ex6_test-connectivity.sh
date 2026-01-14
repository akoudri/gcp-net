#!/bin/bash
# Lab 2.2 - Exercice 2.2.6 : Tester la connectivité inter-régions
# Objectif : Vérifier la communication entre les VMs de différentes régions

set -e

echo "=== Lab 2.2 - Exercice 6 : Tester la connectivité inter-régions ==="
echo ""

# Récupérer l'IP de vm-us
export IP_VM_US=$(gcloud compute instances describe vm-us \
    --zone=us-central1-a \
    --format="get(networkInterfaces[0].networkIP)")

echo "IP de vm-us : $IP_VM_US"
echo ""

echo "Instructions pour tester la connectivité :"
echo ""
echo "1. Connectez-vous à vm-eu via IAP :"
echo "   gcloud compute ssh vm-eu --zone=europe-west1-b --tunnel-through-iap"
echo ""
echo "2. Une fois connecté, exécutez les commandes suivantes :"
echo ""
echo "   # Test de ping"
echo "   ping -c 5 $IP_VM_US"
echo ""
echo "   # Traceroute pour voir le chemin"
echo "   traceroute $IP_VM_US"
echo ""
echo "   # Mesurer la latence"
echo "   mtr -c 10 --report $IP_VM_US"
echo ""
echo "Questions à considérer :"
echo "1. Combien de sauts entre les deux VMs ?"
echo "2. Quelle est la latence moyenne entre Europe et US ?"
echo "3. Le trafic passe-t-il par Internet ou reste-t-il sur le backbone Google ?"
