#!/bin/bash
# Lab 6.9 - Exercice 6.9.3 : Zone privée (vue VPC)
# Objectif : Créer la zone privée avec le même domaine

set -e

echo "=== Lab 6.9 - Exercice 3 : Zone privée (vue VPC) ==="
echo ""

export VPC_NAME="vpc-dns-lab"

echo "VPC : $VPC_NAME"
echo ""

# Créer la zone privée avec le MÊME nom de domaine
echo "Création de la zone privée pour split-horizon..."
gcloud dns managed-zones create zone-split-private \
    --dns-name="example.com." \
    --description="Zone privée pour split-horizon" \
    --visibility=private \
    --networks=$VPC_NAME
echo ""

# Enregistrement privé (IP privée)
echo "Création de l'enregistrement privé avec l'IP privée..."
gcloud dns record-sets create "api-split.example.com." \
    --zone=zone-split-private \
    --type=A \
    --ttl=300 \
    --rrdatas="10.0.0.50"
echo ""

echo "Zone privée configurée avec succès !"
echo ""

# Vérifier
echo "=== Enregistrement privé ==="
gcloud dns record-sets list --zone=zone-split-private \
    --filter="name:api-split"
echo ""

echo "Split-horizon DNS configuré :"
echo "- Vue externe (Internet) : IP publique"
echo "- Vue interne (VPC) : IP privée (10.0.0.50)"
