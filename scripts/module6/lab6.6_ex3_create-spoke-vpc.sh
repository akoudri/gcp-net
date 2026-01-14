#!/bin/bash
# Lab 6.6 - Exercice 6.6.3 : Créer le VPC Spoke
# Objectif : Créer un VPC Spoke qui consommera le DNS du Hub

set -e

echo "=== Lab 6.6 - Exercice 3 : Créer le VPC Spoke ==="
echo ""

export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# VPC Spoke
echo "Création du VPC Spoke..."
gcloud compute networks create vpc-spoke \
    --subnet-mode=custom \
    --description="VPC Spoke consommateur de DNS"
echo ""

echo "Création du sous-réseau Spoke..."
gcloud compute networks subnets create subnet-spoke \
    --network=vpc-spoke \
    --region=$REGION \
    --range=10.20.0.0/24
echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."
gcloud compute firewall-rules create vpc-spoke-allow-internal \
    --network=vpc-spoke \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create vpc-spoke-allow-ssh-iap \
    --network=vpc-spoke \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20
echo ""

# Créer un Cloud Router pour le VPC Spoke
echo "Création du Cloud Router pour le Spoke..."
gcloud compute routers create router-nat-spoke \
    --network=vpc-spoke \
    --region=$REGION
echo ""

# Configurer Cloud NAT pour l'accès Internet sortant
echo "Configuration de Cloud NAT..."
gcloud compute routers nats create nat-dns-peering \
    --router=router-nat-spoke \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
echo ""

# VM dans le spoke
echo "Création de la VM dans le Spoke..."
gcloud compute instances create vm-spoke \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-spoke \
    --subnet=subnet-spoke \
    --private-network-ip=10.20.0.10 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='apt-get update && apt-get install -y dnsutils'
echo ""

echo "VPC Spoke créé avec succès !"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi créer un Cloud Router séparé pour chaque VPC ?"
echo "2. Le peering DNS nécessite-t-il Cloud NAT pour fonctionner ?"
