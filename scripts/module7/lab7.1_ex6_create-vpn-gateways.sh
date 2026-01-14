#!/bin/bash
# Lab 7.1 - Exercice 7.1.6 : Créer les passerelles HA VPN
# Objectif : Créer les passerelles HA VPN pour les deux VPC

set -e

echo "=== Lab 7.1 - Exercice 6 : Créer les passerelles HA VPN ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Passerelle HA VPN pour VPC GCP
echo ">>> Création passerelle HA VPN pour VPC GCP..."
gcloud compute vpn-gateways create vpn-gw-gcp \
    --network=vpc-gcp \
    --region=$REGION

echo ""

# Passerelle HA VPN pour VPC On-premise
echo ">>> Création passerelle HA VPN pour VPC On-premise..."
gcloud compute vpn-gateways create vpn-gw-onprem \
    --network=vpc-onprem \
    --region=$REGION

echo ""

# Récupérer les IPs des passerelles
echo "=== IPs Passerelle GCP ==="
gcloud compute vpn-gateways describe vpn-gw-gcp \
    --region=$REGION \
    --format="yaml(vpnInterfaces)"

echo ""
echo "=== IPs Passerelle On-premise ==="
gcloud compute vpn-gateways describe vpn-gw-onprem \
    --region=$REGION \
    --format="yaml(vpnInterfaces)"

echo ""
echo "=== Passerelles HA VPN créées avec succès ==="
