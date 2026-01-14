#!/bin/bash
# Lab 4.6 - Exercice 4.6.2 : Créer les règles de pare-feu centralisées
# Objectif : Créer des règles de pare-feu centralisées simulant Shared VPC

set -e

echo "=== Lab 4.6 - Exercice 2 : Créer les règles de pare-feu centralisées ==="
echo ""

# Variables
export VPC_SHARED="shared-vpc-sim"

echo "VPC : $VPC_SHARED"
echo ""

# Règle 1: Trafic interne (équipe réseau contrôle)
echo "Création de la règle allow-internal..."
gcloud compute firewall-rules create ${VPC_SHARED}-allow-internal \
    --network=$VPC_SHARED \
    --allow=tcp,udp,icmp \
    --source-ranges=10.100.0.0/16 \
    --description="Trafic interne - géré par équipe réseau"

echo ""

# Règle 2: SSH via IAP (équipe sécurité contrôle)
echo "Création de la règle allow-ssh-iap..."
gcloud compute firewall-rules create ${VPC_SHARED}-allow-ssh-iap \
    --network=$VPC_SHARED \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="SSH IAP - géré par équipe sécurité"

echo ""

# Règle 3: Frontend vers Backend (spécifique aux tags)
echo "Création de la règle frontend-to-backend..."
gcloud compute firewall-rules create ${VPC_SHARED}-frontend-to-backend \
    --network=$VPC_SHARED \
    --allow=tcp:8080 \
    --source-tags=frontend \
    --target-tags=backend \
    --description="Flux frontend vers backend - géré centralement"

echo ""

# Règle 4: Backend vers Data
echo "Création de la règle backend-to-data..."
gcloud compute firewall-rules create ${VPC_SHARED}-backend-to-data \
    --network=$VPC_SHARED \
    --allow=tcp:5432,tcp:3306 \
    --source-tags=backend \
    --target-tags=database \
    --description="Flux backend vers bases de données"

echo ""
echo "Règles de pare-feu centralisées créées avec succès !"
echo ""

# Afficher les règles
echo "=== Règles de pare-feu ==="
gcloud compute firewall-rules list --filter="network:$VPC_SHARED"
