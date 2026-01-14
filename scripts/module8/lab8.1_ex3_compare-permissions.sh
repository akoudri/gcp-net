#!/bin/bash
# Lab 8.1 - Exercice 8.1.3 : Configuration trop permissive vs correcte
# Objectif : Comprendre le principe du moindre privilège

set -e

echo "=== Lab 8.1 - Exercice 3 : Configuration permissive vs correcte ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

echo "IMPORTANT : Ce script démontre les différences entre configurations"
echo "Les commandes marquées ❌ ne seront PAS exécutées"
echo ""

echo "❌ MAUVAISE PRATIQUE : Donner networkAdmin sur tout le projet"
echo "   Ceci permet de modifier TOUS les VPC, sous-réseaux, pare-feu"
echo ""
echo "   gcloud projects add-iam-policy-binding \$PROJECT_ID \\"
echo "       --member=\"user:dev@example.com\" \\"
echo "       --role=\"roles/compute.networkAdmin\""
echo ""

echo "✅ BONNE PRATIQUE : Donner networkUser sur un sous-réseau spécifique"
echo "   Permet seulement d'utiliser ce sous-réseau pour créer des VMs"
echo ""
echo "   Exemple de commande (ne sera pas exécutée) :"
echo "   gcloud compute networks subnets add-iam-policy-binding subnet-dev \\"
echo "       --region=europe-west1 \\"
echo "       --member=\"user:dev@example.com\" \\"
echo "       --role=\"roles/compute.networkUser\""
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi est-ce dangereux de donner networkAdmin au niveau projet ?"
echo "2. Comment déterminer le niveau de permission approprié ?"
echo "3. Quels sont les risques d'une permission trop élevée ?"
