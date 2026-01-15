#!/bin/bash
# Lab 6.4 - Exercice 6.4.2 : Configurer Cloud NAT
# Objectif : Configurer Cloud NAT pour le DNS server

set -e

echo "=== Lab 6.4 - Exercice 2 : Configurer Cloud NAT ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export REGION="europe-west1"

echo "VPC : $VPC_NAME"
echo "Région : $REGION"
echo ""

# Créer un Cloud Router (si pas déjà créé)
echo "Création/vérification du Cloud Router..."
gcloud compute routers create router-nat-dns \
    --network=$VPC_NAME \
    --region=$REGION 2>/dev/null || echo "Router déjà existant"
echo ""

# Configurer Cloud NAT pour l'accès Internet sortant
echo "Configuration de Cloud NAT..."
# Vérifier si NAT existe déjà
if gcloud compute routers nats describe nat-dns-forward --router=router-nat-dns --region=$REGION &>/dev/null; then
    echo "NAT nat-dns-forward existe déjà"
elif gcloud compute routers nats describe nat-dns-lab --router=router-nat-dns --region=$REGION &>/dev/null; then
    echo "NAT nat-dns-lab existe déjà et couvre tous les sous-réseaux (réutilisation)"
else
    gcloud compute routers nats create nat-dns-forward \
        --router=router-nat-dns \
        --region=$REGION \
        --nat-all-subnet-ip-ranges \
        --auto-allocate-nat-external-ips
fi
echo ""

echo "Cloud NAT configuré avec succès !"
echo ""

# Vérifier la configuration
echo "=== Vérification du Cloud Router ==="
gcloud compute routers describe router-nat-dns --region=$REGION
echo ""

echo "=== Vérification de Cloud NAT ==="
# Décrire le NAT qui existe (nat-dns-forward ou nat-dns-lab)
if gcloud compute routers nats describe nat-dns-forward --router=router-nat-dns --region=$REGION &>/dev/null; then
    gcloud compute routers nats describe nat-dns-forward --router=router-nat-dns --region=$REGION
else
    echo "Utilisation du NAT existant: nat-dns-lab"
    gcloud compute routers nats describe nat-dns-lab --router=router-nat-dns --region=$REGION
fi
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi le serveur DNS on-premise simulé a-t-il besoin de Cloud NAT ?"
echo "2. Comment Cloud NAT permet-il au serveur dnsmasq d'installer des paquets depuis Internet ?"
