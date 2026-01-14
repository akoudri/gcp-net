#!/bin/bash
# Lab 5.4 - Exercice 5.4.4 : Observer les ressources PSA
# Objectif : Voir comment PSA partage la connexion entre les services

set -e

echo "=== Lab 5.4 - Exercice 4 : Observer les ressources PSA ==="
echo ""

export VPC_NAME="vpc-private-access"

# Voir toutes les adresses réservées pour PSA
echo "=== Adresses réservées pour VPC Peering (PSA) ==="
gcloud compute addresses list --global --filter="purpose=VPC_PEERING" --format="table(name,address,prefixLength,network,purpose)"

echo ""

# Voir le peering
echo "=== VPC Peerings ==="
gcloud compute networks peerings list --network=$VPC_NAME --format="table(name,network,peerNetwork,state,stateDetails)"

echo ""

# Récupérer les IPs des services
SQL_IP=$(gcloud sql instances describe sql-private --format="get(ipAddresses[0].ipAddress)" 2>/dev/null || echo "N/A")
REDIS_IP=$(gcloud redis instances describe redis-private --region=europe-west1 --format="get(host)" 2>/dev/null || echo "N/A")

echo "=== IPs des services managés ==="
echo "Cloud SQL : $SQL_IP"
echo "Redis : $REDIS_IP"
echo ""

echo "=== Observations ==="
echo ""
echo "✓ Cloud SQL et Redis partagent la même connexion PSA"
echo "✓ Ils ont des IPs différentes dans la plage réservée (10.100.0.0/24)"
echo "✓ Un seul VPC Peering est nécessaire pour tous les services"
echo "✓ La plage /24 permet jusqu'à 254 IPs pour les services"
echo ""
echo "Avantages de PSA :"
echo "- Pas d'IP publique nécessaire"
echo "- Connexion privée et sécurisée"
echo "- Faible latence (réseau privé Google)"
echo "- Automatisation de la configuration réseau"
