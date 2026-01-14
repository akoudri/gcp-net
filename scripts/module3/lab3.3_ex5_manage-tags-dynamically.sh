#!/bin/bash
# Lab 3.3 - Exercice 3.3.5 : Ajouter/Retirer des tags dynamiquement
# Objectif : Comprendre l'impact dynamique des tags réseau

set -e

echo "=== Lab 3.3 - Exercice 5 : Ajouter/Retirer des tags dynamiquement ==="
echo ""

export REGION_EU="europe-west1"

echo "Option 1 : Ajouter le tag à client2"
echo ""
echo "  gcloud compute instances add-tags client2 \\"
echo "      --zone=${REGION_EU}-b \\"
echo "      --tags=needs-proxy"
echo ""
echo "  # Retester depuis client2 - maintenant le trafic passe par le proxy"
echo ""

echo "Option 2 : Retirer le tag de client2"
echo ""
echo "  gcloud compute instances remove-tags client2 \\"
echo "      --zone=${REGION_EU}-b \\"
echo "      --tags=needs-proxy"
echo ""

echo "Questions à considérer :"
echo "1. Le changement de tag est-il instantané ?"
echo "2. Les connexions existantes sont-elles affectées ?"
echo ""
echo "Note : Ce script affiche les instructions. Les opérations doivent être effectuées manuellement."
echo ""
