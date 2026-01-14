#!/bin/bash
# Lab 8.4 - Exercice 8.4.4 : Créer une Regional Network Firewall Policy
# Objectif : Créer une politique de pare-feu régionale

set -e

echo "=== Lab 8.4 - Exercice 4 : Créer une Regional Network Firewall Policy ==="
echo ""

export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer une politique régionale pour l'Europe
echo ">>> Création de la politique régionale..."
gcloud compute network-firewall-policies create europe-policy \
    --region=$REGION \
    --description="Politique régionale Europe West 1"

echo ""
echo "Politique régionale créée !"
echo ""

# Règle spécifique à la région
echo ">>> Ajout d'une règle spécifique à la région..."
gcloud compute network-firewall-policies rules create 100 \
    --firewall-policy=europe-policy \
    --firewall-policy-region=$REGION \
    --direction=INGRESS \
    --action=allow \
    --layer4-configs=tcp:22 \
    --src-ip-ranges=10.0.0.0/8 \
    --description="SSH interne Europe uniquement"

echo ""
echo "Règle ajoutée avec succès !"
echo ""

# Associer au VPC pour cette région
echo ">>> Association de la politique au VPC..."
gcloud compute network-firewall-policies associations create \
    --firewall-policy=europe-policy \
    --firewall-policy-region=$REGION \
    --network=$VPC_NAME \
    --name=assoc-europe-${VPC_NAME}

echo ""
echo "Politique régionale configurée avec succès !"
echo ""

# Afficher la configuration
echo "=== Configuration de la politique régionale ==="
gcloud compute network-firewall-policies describe europe-policy \
    --region=$REGION

echo ""
echo "Questions à considérer :"
echo "1. Quelle est la différence entre une politique globale et régionale ?"
echo "2. Dans quel ordre sont évaluées les politiques globales vs régionales ?"
echo "3. Quand utiliser une politique régionale plutôt que globale ?"
