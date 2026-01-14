#!/bin/bash
# Lab 8.3 - Exercice 8.3.3 : Configurer Cloud NAT pour les VMs sans IP publique
# Objectif : Assurer l'accès Internet sortant pour les VMs avec Service Accounts

set -e

echo "=== Lab 8.3 - Exercice 3 : Configurer Cloud NAT ==="
echo ""

export VPC_NAME="vpc-security-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Vérifier si le Cloud Router existe déjà
if gcloud compute routers describe router-nat-security --region=$REGION &>/dev/null; then
    echo "Cloud Router 'router-nat-security' existe déjà."
    echo "Réutilisation du Cloud NAT existant..."
else
    echo ">>> Création du Cloud Router..."
    gcloud compute routers create router-nat-firewall \
        --network=$VPC_NAME \
        --region=$REGION

    echo ""
    echo ">>> Configuration de Cloud NAT..."
    gcloud compute routers nats create nat-firewall \
        --router=router-nat-firewall \
        --region=$REGION \
        --auto-allocate-nat-external-ips \
        --nat-all-subnet-ip-ranges \
        --enable-logging

    echo ""
    echo "Cloud NAT configuré avec succès !"
fi

echo ""

# Vérifier la configuration
echo "=== Vérification de la configuration ==="
ROUTER_NAME=$(gcloud compute routers list --filter="network:$VPC_NAME AND region:$REGION" --format="get(name)" | head -1)

if [ -n "$ROUTER_NAME" ]; then
    echo ">>> Configuration Cloud Router : $ROUTER_NAME"
    gcloud compute routers describe $ROUTER_NAME --region=$REGION

    echo ""
    NAT_NAME=$(gcloud compute routers nats list --router=$ROUTER_NAME --region=$REGION --format="get(name)" | head -1)
    if [ -n "$NAT_NAME" ]; then
        echo ">>> Configuration Cloud NAT : $NAT_NAME"
        gcloud compute routers nats describe $NAT_NAME \
            --router=$ROUTER_NAME \
            --region=$REGION
    fi
fi

echo ""
echo "Questions pédagogiques :"
echo "1. Comment Cloud NAT interagit-il avec les règles de pare-feu basées sur Service Accounts ?"
echo "2. Pourquoi est-il important de combiner Cloud NAT avec l'absence d'IP publique sur les VMs ?"
echo "3. Quels sont les avantages de Cloud NAT en termes d'audit et de traçabilité ?"
