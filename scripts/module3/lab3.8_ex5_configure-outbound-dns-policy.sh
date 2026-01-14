#!/bin/bash
# Lab 3.8 - Exercice 3.8.5 : Créer une politique DNS pour le routage sortant
# Objectif : Configurer des serveurs DNS alternatifs

set -e

echo "=== Lab 3.8 - Exercice 5 : Créer une politique DNS pour le routage sortant ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Créer une politique de serveur alternatif
echo "Création de la politique DNS sortante..."
gcloud dns policies create outbound-dns-policy \
    --description="Use custom DNS servers" \
    --networks=$VPC_NAME \
    --alternative-name-servers="8.8.8.8,1.1.1.1"

echo ""
echo "Politique DNS sortante créée avec succès !"
echo ""

echo "Note : Cette politique remplace le DNS GCP par défaut pour toutes les requêtes."
echo ""

echo "Questions à considérer :"
echo "1. Quand utiliserait-on une zone de forwarding ?"
echo "2. Quelle est la différence entre une zone de forwarding et une politique DNS ?"
echo ""

echo "Réponses :"
echo "1. Zone de forwarding : Pour des domaines spécifiques (corp.example)"
echo "2. Politique DNS : Pour toutes les requêtes DNS du VPC"
echo ""
