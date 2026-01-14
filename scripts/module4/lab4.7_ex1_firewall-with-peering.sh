#!/bin/bash
# Lab 4.7 - Exercice 4.7.1 : Pare-feu avec VPC Peering
# Objectif : Comprendre comment les pare-feux fonctionnent avec VPC Peering

set -e

echo "=== Lab 4.7 - Exercice 1 : Pare-feu avec VPC Peering ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"

echo "Rappel de l'architecture: vpc-alpha ↔ vpc-beta (peerés)"
echo ""

# Vérifier les règles existantes
echo "=== Règles de pare-feu VPC Alpha ==="
gcloud compute firewall-rules list --filter="network=$VPC_ALPHA"
echo ""

echo "=== Règles de pare-feu VPC Beta ==="
gcloud compute firewall-rules list --filter="network=$VPC_BETA"
echo ""

echo "POINT IMPORTANT:"
echo "Le trafic peeré arrive comme du trafic INTERNE"
echo "La source sera l'IP du VPC peer, pas une IP externe"
echo ""

# Créer une règle spécifique pour autoriser HTTP depuis VPC Beta
echo "Création d'une règle pour autoriser HTTP depuis VPC Beta..."
gcloud compute firewall-rules create ${VPC_ALPHA}-allow-http-from-beta \
    --network=$VPC_ALPHA \
    --allow=tcp:80,tcp:443 \
    --source-ranges=10.20.0.0/16 \
    --target-tags=web \
    --description="HTTP depuis VPC Beta (peeré)"

echo ""
echo "Règle créée !"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi spécifier la plage IP source du VPC peer ?"
echo "2. Les tags de firewall sont-ils échangés via le peering ?"
