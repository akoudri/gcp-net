#!/bin/bash
# Lab 5.3 - Exercice 5.3.7 : Créer une VM pour tester la connexion
# Objectif : Déployer une VM cliente pour se connecter à Cloud SQL

set -e

echo "=== Lab 5.3 - Exercice 7 : Créer une VM cliente ==="
echo ""

export VPC_NAME="vpc-private-access"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# Créer un sous-réseau pour les applications
echo "Création du sous-réseau pour les applications..."
gcloud compute networks subnets create subnet-app \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.1.0/24 \
    --enable-private-ip-google-access

echo ""
echo "Sous-réseau créé !"
echo ""

# Règle de pare-feu pour la communication interne
echo "Création de la règle de pare-feu pour la communication interne..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-internal \
    --network=$VPC_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

echo ""
echo "Règle de pare-feu créée !"
echo ""

# VM cliente
echo "Création de la VM cliente..."
gcloud compute instances create vm-sql-client \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-app \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y postgresql-client'

echo ""
echo "=== VM cliente créée ! ==="
echo ""
echo "Nom : vm-sql-client"
echo "Sous-réseau : subnet-app (10.0.1.0/24)"
echo "IP externe : Aucune"
echo ""
echo "La VM installe automatiquement le client PostgreSQL."
echo "Attendez 1-2 minutes avant de l'utiliser."
