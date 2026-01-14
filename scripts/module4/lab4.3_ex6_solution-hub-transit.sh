#!/bin/bash
# Lab 4.3 - Exercice 4.3.6 : Solution 2 - Transit via une appliance (Hub)
# Objectif : Configurer vm-beta comme routeur/hub pour le transit

set -e

echo "=== Lab 4.3 - Exercice 6 : Solution 2 - Transit via une appliance ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_GAMMA="vpc-gamma"
export VPC_BETA="vpc-beta"
export ZONE="europe-west1-b"

echo "Configuration d'une architecture hub-and-spoke avec vm-beta comme hub..."
echo ""

# Supprimer le peering direct Alpha ↔ Gamma pour simuler le scénario hub-and-spoke
echo "Suppression du peering direct Alpha ↔ Gamma..."
gcloud compute networks peerings delete peering-alpha-to-gamma \
    --network=$VPC_ALPHA --quiet 2>/dev/null || true
gcloud compute networks peerings delete peering-gamma-to-alpha \
    --network=$VPC_GAMMA --quiet 2>/dev/null || true

echo ""
echo "Peering direct supprimé."
echo ""

# Note: can-ip-forward doit être défini à la création
# Recréer vm-beta avec can-ip-forward
echo "Recréation de vm-beta avec IP forwarding activé..."
gcloud compute instances delete vm-beta --zone=$ZONE --quiet 2>/dev/null || true

sleep 5

gcloud compute instances create vm-beta \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_BETA \
    --subnet=subnet-beta \
    --private-network-ip=10.20.1.10 \
    --no-address \
    --can-ip-forward \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        apt-get update && apt-get install -y iptables'

echo ""
echo "vm-beta recréée en tant que routeur/hub !"
echo ""

echo "Note : Cette configuration est complexe et nécessite que vm-beta soit dans le chemin réseau."
echo "En production, utilisez Network Connectivity Center pour un transit managé."
echo ""
