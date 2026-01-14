#!/bin/bash
# Lab 7.1 - Exercice 7.1.7 : Créer les tunnels VPN (4 tunnels au total)
# Objectif : Créer les tunnels VPN entre les deux passerelles

set -e

echo "=== Lab 7.1 - Exercice 7 : Créer les tunnels VPN ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Générer des secrets partagés sécurisés
echo ">>> Génération des secrets partagés..."
SECRET_0=$(openssl rand -base64 24)
SECRET_1=$(openssl rand -base64 24)

echo "Secret Tunnel 0: $SECRET_0"
echo "Secret Tunnel 1: $SECRET_1"
echo ""

# ===== Tunnels côté GCP =====
echo ">>> Création des tunnels côté GCP..."

# Tunnel 0: Interface 0 GCP → Interface 0 On-premise
echo "  - Tunnel 0 (Interface 0 GCP → Interface 0 On-premise)"
gcloud compute vpn-tunnels create tunnel-gcp-to-onprem-0 \
    --vpn-gateway=vpn-gw-gcp \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-onprem \
    --peer-gcp-gateway-region=$REGION \
    --interface=0 \
    --ike-version=2 \
    --shared-secret="$SECRET_0" \
    --router=router-gcp \
    --router-region=$REGION

# Tunnel 1: Interface 1 GCP → Interface 1 On-premise
echo "  - Tunnel 1 (Interface 1 GCP → Interface 1 On-premise)"
gcloud compute vpn-tunnels create tunnel-gcp-to-onprem-1 \
    --vpn-gateway=vpn-gw-gcp \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-onprem \
    --peer-gcp-gateway-region=$REGION \
    --interface=1 \
    --ike-version=2 \
    --shared-secret="$SECRET_1" \
    --router=router-gcp \
    --router-region=$REGION

echo ""

# ===== Tunnels côté On-premise =====
echo ">>> Création des tunnels côté On-premise..."

# Tunnel 0: Interface 0 On-premise → Interface 0 GCP
echo "  - Tunnel 0 (Interface 0 On-premise → Interface 0 GCP)"
gcloud compute vpn-tunnels create tunnel-onprem-to-gcp-0 \
    --vpn-gateway=vpn-gw-onprem \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-gcp \
    --peer-gcp-gateway-region=$REGION \
    --interface=0 \
    --ike-version=2 \
    --shared-secret="$SECRET_0" \
    --router=router-onprem \
    --router-region=$REGION

# Tunnel 1: Interface 1 On-premise → Interface 1 GCP
echo "  - Tunnel 1 (Interface 1 On-premise → Interface 1 GCP)"
gcloud compute vpn-tunnels create tunnel-onprem-to-gcp-1 \
    --vpn-gateway=vpn-gw-onprem \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-gcp \
    --peer-gcp-gateway-region=$REGION \
    --interface=1 \
    --ike-version=2 \
    --shared-secret="$SECRET_1" \
    --router=router-onprem \
    --router-region=$REGION

echo ""

# Vérifier les tunnels
echo "=== Tunnels VPN créés ==="
gcloud compute vpn-tunnels list --filter="region:$REGION"
