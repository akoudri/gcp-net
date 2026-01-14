#!/bin/bash
# Lab 6.5 - Exercice 6.5.1 : Créer une politique DNS avec inbound forwarding
# Objectif : Activer l'inbound forwarding pour permettre la résolution depuis on-premise

set -e

echo "=== Lab 6.5 - Exercice 1 : Créer une politique DNS avec inbound forwarding ==="
echo ""

export VPC_NAME="vpc-dns-lab"

echo "VPC : $VPC_NAME"
echo ""

# Créer la politique DNS
echo "Création de la politique DNS avec inbound forwarding..."
gcloud dns policies create policy-inbound \
    --networks=$VPC_NAME \
    --enable-inbound-forwarding \
    --description="Politique avec inbound forwarding"
echo ""

echo "Politique DNS créée avec succès !"
echo ""

# Vérifier la création
echo "=== Détails de la politique DNS ==="
gcloud dns policies describe policy-inbound
echo ""

# Lister les adresses de forwarding inbound créées automatiquement
echo "=== Adresses de forwarding inbound ==="
gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER" \
    --format="table(name,address,region,subnetwork)"
