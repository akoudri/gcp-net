#!/bin/bash
# Lab 3.8 - Exercice 3.8.4 : Configurer une politique DNS de serveur entrant
# Objectif : Permettre aux clients on-premise de résoudre les noms GCP

set -e

echo "=== Lab 3.8 - Exercice 4 : Configurer une politique DNS de serveur entrant ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Permettre aux clients on-premise de résoudre les noms GCP
echo "Création de la politique DNS entrante..."
gcloud dns policies create inbound-dns-policy \
    --description="Allow inbound DNS queries" \
    --networks=$VPC_NAME \
    --enable-inbound-forwarding

echo ""
echo "Politique DNS entrante créée avec succès !"
echo ""

echo "Cette configuration crée des IPs dans chaque sous-réseau pour recevoir les requêtes DNS."
echo ""

# Voir les adresses créées
echo "=== Adresses DNS Resolver ==="
gcloud compute addresses list --filter="purpose=DNS_RESOLVER"
echo ""

echo "Note : Ces adresses peuvent être utilisées par vos serveurs on-premise"
echo "       pour résoudre les noms Cloud DNS privés."
echo ""
