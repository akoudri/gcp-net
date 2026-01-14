#!/bin/bash
# Lab 7.1 - Exercice 7.1.8 : Configurer les interfaces et peers BGP
# Objectif : Configurer les interfaces BGP et établir les sessions BGP

set -e

echo "=== Lab 7.1 - Exercice 8 : Configurer les interfaces et peers BGP ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# ===== Interfaces BGP côté GCP =====
echo ">>> Configuration des interfaces BGP côté GCP..."

# Interface pour tunnel 0
echo "  - Interface BGP pour tunnel 0"
gcloud compute routers add-interface router-gcp \
    --interface-name=bgp-if-gcp-0 \
    --vpn-tunnel=tunnel-gcp-to-onprem-0 \
    --ip-address=169.254.0.1 \
    --mask-length=30 \
    --region=$REGION

# Interface pour tunnel 1
echo "  - Interface BGP pour tunnel 1"
gcloud compute routers add-interface router-gcp \
    --interface-name=bgp-if-gcp-1 \
    --vpn-tunnel=tunnel-gcp-to-onprem-1 \
    --ip-address=169.254.1.1 \
    --mask-length=30 \
    --region=$REGION

echo ""

# ===== Interfaces BGP côté On-premise =====
echo ">>> Configuration des interfaces BGP côté On-premise..."

# Interface pour tunnel 0
echo "  - Interface BGP pour tunnel 0"
gcloud compute routers add-interface router-onprem \
    --interface-name=bgp-if-onprem-0 \
    --vpn-tunnel=tunnel-onprem-to-gcp-0 \
    --ip-address=169.254.0.2 \
    --mask-length=30 \
    --region=$REGION

# Interface pour tunnel 1
echo "  - Interface BGP pour tunnel 1"
gcloud compute routers add-interface router-onprem \
    --interface-name=bgp-if-onprem-1 \
    --vpn-tunnel=tunnel-onprem-to-gcp-1 \
    --ip-address=169.254.1.2 \
    --mask-length=30 \
    --region=$REGION

echo ""

# ===== Peers BGP côté GCP =====
echo ">>> Configuration des peers BGP côté GCP..."

echo "  - Peer BGP pour tunnel 0"
gcloud compute routers add-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-0 \
    --peer-asn=65002 \
    --interface=bgp-if-gcp-0 \
    --peer-ip-address=169.254.0.2 \
    --region=$REGION

echo "  - Peer BGP pour tunnel 1"
gcloud compute routers add-bgp-peer router-gcp \
    --peer-name=bgp-peer-onprem-1 \
    --peer-asn=65002 \
    --interface=bgp-if-gcp-1 \
    --peer-ip-address=169.254.1.2 \
    --region=$REGION

echo ""

# ===== Peers BGP côté On-premise =====
echo ">>> Configuration des peers BGP côté On-premise..."

echo "  - Peer BGP pour tunnel 0"
gcloud compute routers add-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-0 \
    --peer-asn=65001 \
    --interface=bgp-if-onprem-0 \
    --peer-ip-address=169.254.0.1 \
    --region=$REGION

echo "  - Peer BGP pour tunnel 1"
gcloud compute routers add-bgp-peer router-onprem \
    --peer-name=bgp-peer-gcp-1 \
    --peer-asn=65001 \
    --interface=bgp-if-onprem-1 \
    --peer-ip-address=169.254.1.1 \
    --region=$REGION

echo ""
echo "=== Configuration BGP terminée ==="
