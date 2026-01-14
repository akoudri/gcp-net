#!/bin/bash
# Lab 4.9 - Exercice 4.9.4 : Contrôler l'accès partenaire
# Objectif : Configurer des règles pour restreindre l'accès du partenaire

set -e

echo "=== Lab 4.9 - Exercice 4 : Contrôler l'accès partenaire ==="
echo ""

# Variables
export VPC_HUB="vpc-hub"

echo "Configuration des règles d'accès pour le partenaire..."
echo ""
echo "Le partenaire ne doit accéder qu'à la production, pas au dev/staging"
echo ""

# Règle: Autoriser partenaire → prod uniquement
echo "Création de la règle allow-partner-to-prod..."
gcloud compute firewall-rules create ${VPC_HUB}-allow-partner-to-prod \
    --network=$VPC_HUB \
    --allow=tcp:443,tcp:8080 \
    --source-ranges=10.200.0.0/16 \
    --target-tags=prod \
    --description="Partenaire peut accéder à prod"

echo ""

# Règle: Bloquer partenaire → dev/staging (explicit deny)
echo "Création de la règle deny-partner-to-nonprod..."
gcloud compute firewall-rules create ${VPC_HUB}-deny-partner-to-nonprod \
    --network=$VPC_HUB \
    --action=DENY \
    --rules=all \
    --source-ranges=10.200.0.0/16 \
    --target-tags=dev,staging \
    --priority=900 \
    --description="Partenaire ne peut PAS accéder à dev/staging"

echo ""
echo "Règles d'accès configurées avec succès !"
echo ""

# Afficher les règles
echo "=== Règles de contrôle d'accès ==="
gcloud compute firewall-rules list --filter="network:$VPC_HUB AND sourceRanges:10.200.0.0/16"
