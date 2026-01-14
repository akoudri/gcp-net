#!/bin/bash
# Lab 7.1 - Exercice 7.1.2 : Configurer Cloud NAT pour l'accès Internet
# Objectif : Configurer Cloud NAT pour permettre l'accès Internet sortant depuis les VMs

set -e

echo "=== Lab 7.1 - Exercice 2 : Configurer Cloud NAT ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Cloud NAT pour le VPC GCP
echo ">>> Configuration Cloud NAT pour VPC GCP..."
gcloud compute routers nats create nat-vpn-gcp \
    --router=router-gcp \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""

# Cloud NAT pour le VPC On-premise
echo ">>> Configuration Cloud NAT pour VPC On-premise..."
gcloud compute routers nats create nat-vpn-onprem \
    --router=router-onprem \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""

# Vérifier la configuration Cloud NAT
echo "=== Cloud NAT VPC GCP ==="
gcloud compute routers nats describe nat-vpn-gcp \
    --router=router-gcp \
    --region=$REGION

echo ""
echo "=== Cloud NAT VPC On-premise ==="
gcloud compute routers nats describe nat-vpn-onprem \
    --router=router-onprem \
    --region=$REGION

echo ""
echo "=== Configuration Cloud NAT terminée ==="
echo ""
echo "Questions :"
echo "1. Pourquoi avons-nous besoin de Cloud NAT dans cette architecture avec VPN ?"
echo "2. Que se passerait-il si les VMs tentaient d'accéder à Internet sans Cloud NAT ?"
echo "3. Comment Cloud NAT interagit-il avec BGP et les tunnels VPN ?"
