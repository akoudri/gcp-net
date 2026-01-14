#!/bin/bash
# Lab 5.1 - Exercice 5.1.1 : Créer l'infrastructure de test
# Objectif : Créer le VPC et les ressources de base pour tester Private Google Access

set -e

echo "=== Lab 5.1 - Exercice 1 : Créer l'infrastructure de test ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_NAME="vpc-private-access"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer le VPC
echo "Création du VPC..."
gcloud compute networks create $VPC_NAME \
    --subnet-mode=custom \
    --description="VPC pour tester la connectivité privée"

echo ""
echo "VPC créé avec succès !"
echo ""

# Créer un sous-réseau SANS PGA initialement
echo "Création du sous-réseau sans PGA..."
gcloud compute networks subnets create subnet-pga \
    --network=$VPC_NAME \
    --region=$REGION \
    --range=10.0.0.0/24 \
    --no-enable-private-ip-google-access

echo ""
echo "Sous-réseau créé avec succès !"
echo ""

# Vérifier que PGA est désactivé
echo "=== Vérification de l'état de PGA ==="
PGA_STATUS=$(gcloud compute networks subnets describe subnet-pga \
    --region=$REGION \
    --format="get(privateIpGoogleAccess)")
echo "Private Google Access: $PGA_STATUS"
echo "(Attendu: False)"
echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."

echo "- Règle pour SSH via IAP..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-ssh-iap \
    --network=$VPC_NAME \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="SSH via IAP"

echo "- Règle pour egress vers APIs Google..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-egress-google \
    --network=$VPC_NAME \
    --direction=EGRESS \
    --allow=tcp:443 \
    --destination-ranges=199.36.153.0/24 \
    --description="Egress vers APIs Google"

echo ""
echo "=== Infrastructure créée avec succès ! ==="
echo ""
echo "Ressources créées :"
echo "- VPC: $VPC_NAME"
echo "- Sous-réseau: subnet-pga (10.0.0.0/24)"
echo "- PGA: Désactivé"
echo "- Règles de pare-feu: 2"
