#!/bin/bash
# Lab 8.4 - Exercice 8.4.3 : Associer la politique au VPC
# Objectif : Attacher la politique de pare-feu à un VPC

set -e

echo "=== Lab 8.4 - Exercice 3 : Associer la politique au VPC ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

# Associer au VPC
echo ">>> Association de la politique au VPC..."
gcloud compute network-firewall-policies associations create \
    --firewall-policy=global-security-policy \
    --global-firewall-policy \
    --network=$VPC_NAME \
    --name=assoc-${VPC_NAME}

echo ""
echo "Politique associée avec succès !"
echo ""

# Vérifier l'association
echo "=== Vérification de l'association ==="
gcloud compute network-firewall-policies describe global-security-policy \
    --global \
    --format="yaml(associations)"

echo ""
echo "Questions à considérer :"
echo "1. Peut-on associer une même politique à plusieurs VPCs ?"
echo "2. Dans quel ordre les règles sont-elles évaluées (Network Policy vs VPC Rules) ?"
echo "3. Comment supprimer une association sans supprimer la politique ?"
