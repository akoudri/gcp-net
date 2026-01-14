#!/bin/bash
# Lab 5.3 - Exercice 5.3.4 : Créer une instance Cloud SQL avec IP privée
# Objectif : Déployer Cloud SQL utilisant PSA

set -e

echo "=== Lab 5.3 - Exercice 4 : Créer Cloud SQL avec IP privée ==="
echo ""

export VPC_NAME="vpc-private-access"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Activer l'API Cloud SQL
echo "Activation de l'API Cloud SQL..."
gcloud services enable sqladmin.googleapis.com

echo ""

# Créer l'instance Cloud SQL PostgreSQL
echo "Création de l'instance Cloud SQL PostgreSQL..."
echo "⚠️  Cette opération prend 5-10 minutes. Soyez patient..."
echo ""

gcloud sql instances create sql-private \
    --database-version=POSTGRES_14 \
    --tier=db-f1-micro \
    --region=$REGION \
    --network=$VPC_NAME \
    --no-assign-ip \
    --storage-size=10GB \
    --storage-type=HDD

echo ""
echo "Instance Cloud SQL créée avec succès !"
echo ""

# Vérifier l'état
echo "=== Détails de l'instance Cloud SQL ==="
gcloud sql instances describe sql-private \
    --format="yaml(name,state,ipAddresses,settings.ipConfiguration)"

echo ""
echo "=== Instance Cloud SQL créée ! ==="
echo ""
echo "Nom : sql-private"
echo "Version : PostgreSQL 14"
echo "Réseau : $VPC_NAME"
echo "IP publique : Aucune (--no-assign-ip)"
echo ""
echo "L'instance a reçu une IP privée de la plage PSA (10.100.0.0/24)."
