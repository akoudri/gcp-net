#!/bin/bash
# Lab 5.4 - Exercice 5.4.2 : Créer une instance Memorystore Redis
# Objectif : Déployer Redis avec PSA

set -e

echo "=== Lab 5.4 - Exercice 2 : Créer Memorystore Redis ==="
echo ""

export VPC_NAME="vpc-private-access"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer l'instance Redis avec IP privée
# Elle utilisera la même connexion PSA que Cloud SQL
echo "Création de l'instance Memorystore Redis..."
echo "⚠️  Cette opération prend 5-10 minutes. Soyez patient..."
echo ""

gcloud redis instances create redis-private \
    --region=$REGION \
    --network=$VPC_NAME \
    --tier=basic \
    --size=1 \
    --redis-version=redis_6_x

echo ""
echo "Instance Redis créée avec succès !"
echo ""

# Vérifier l'état
echo "=== Détails de l'instance Redis ==="
gcloud redis instances describe redis-private \
    --region=$REGION \
    --format="yaml(name,state,host,port,currentLocationId)"

echo ""

# Récupérer l'IP Redis
export REDIS_IP=$(gcloud redis instances describe redis-private \
    --region=$REGION \
    --format="get(host)")

echo "=== Instance Redis créée ! ==="
echo ""
echo "Nom : redis-private"
echo "IP privée : $REDIS_IP"
echo "Port : 6379"
echo "Tier : Basic"
echo ""

# Sauvegarder l'IP pour les scripts suivants
echo "export REDIS_IP=$REDIS_IP" > /tmp/redis-ip.env
echo "L'IP a été sauvegardée dans /tmp/redis-ip.env"
