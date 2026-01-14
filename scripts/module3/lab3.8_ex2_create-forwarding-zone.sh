#!/bin/bash
# Lab 3.8 - Exercice 3.8.2 : Créer une zone de forwarding
# Objectif : Configurer le forwarding DNS vers des serveurs externes

set -e

echo "=== Lab 3.8 - Exercice 2 : Créer une zone de forwarding ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Zone de forwarding vers un DNS externe (ex: on-premise)
# Note: Les IPs cibles doivent être accessibles (via VPN/Interconnect en production)
echo "Création de la zone de forwarding..."
gcloud dns managed-zones create forward-zone \
    --description="Forward to external DNS" \
    --dns-name="corp.example." \
    --visibility=private \
    --networks=$VPC_NAME \
    --forwarding-targets="8.8.8.8,8.8.4.4"

echo ""
echo "Zone de forwarding créée avec succès !"
echo ""

# Vérifier la configuration
echo "=== Configuration de la zone de forwarding ==="
gcloud dns managed-zones describe forward-zone
echo ""

echo "Note : En production, remplacez 8.8.8.8 par l'IP de votre serveur DNS on-premise"
echo "       (accessible via VPN)."
echo ""
