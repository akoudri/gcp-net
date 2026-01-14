#!/bin/bash
# Lab 2.6 - Exercice 2.6.4 : Modifier le mode de routage
# Objectif : Démontrer qu'on peut changer le mode de routage

set -e

echo "=== Lab 2.6 - Exercice 4 : Modifier le mode de routage ==="
echo ""

# Passer le VPC régional en mode global
echo "Passage du VPC régional en mode global..."
gcloud compute networks update vpc-regional \
    --bgp-routing-mode=global

echo ""

# Vérifier le changement
echo "=== Nouveau mode de routage ==="
gcloud compute networks describe vpc-regional \
    --format="get(routingConfig.routingMode)"

echo ""
echo "Mode de routage modifié avec succès !"
echo ""

echo "Questions à considérer :"
echo "1. Quand le mode de routage global est-il nécessaire ?"
echo "   → Lorsqu'on veut que les routes BGP soient visibles dans toutes les régions"
echo ""
echo "2. Le changement de mode affecte-t-il les VMs existantes ?"
echo "   → Non, le changement est transparent pour les VMs"
echo ""
echo "3. Quel est l'impact sur les routes apprises via BGP ?"
echo "   → En mode global, elles deviennent visibles dans toutes les régions"
