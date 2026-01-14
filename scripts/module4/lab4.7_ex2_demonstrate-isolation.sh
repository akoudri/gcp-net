#!/bin/bash
# Lab 4.7 - Exercice 4.7.2 : Démontrer l'isolation par défaut
# Objectif : Montrer que le peering n'autorise pas automatiquement le trafic

set -e

echo "=== Lab 4.7 - Exercice 2 : Démontrer l'isolation par défaut ==="
echo ""

# Variables
export VPC_ALPHA="vpc-alpha"
export VPC_BETA="vpc-beta"
export ZONE="europe-west1-b"

echo "Démonstration : Le peering établit la connectivité, mais les pare-feux contrôlent le trafic"
echo ""

# Supprimer temporairement les règles allow-internal
echo "Suppression temporaire des règles allow-internal..."
gcloud compute firewall-rules delete ${VPC_ALPHA}-allow-internal --quiet 2>/dev/null || true
gcloud compute firewall-rules delete ${VPC_BETA}-allow-internal --quiet 2>/dev/null || true

echo ""
echo "Règles supprimées."
echo ""

# Tester la connectivité (devrait échouer même avec peering actif)
echo "Test de connectivité sans règles allow-internal..."
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test sans règle allow-internal ==="
ping -c 3 10.20.1.10 && echo "SUCCESS" || echo "BLOCKED by firewall"
EOF

echo ""

# Rétablir les règles
echo "Rétablissement des règles allow-internal..."
gcloud compute firewall-rules create ${VPC_ALPHA}-allow-internal \
    --network=$VPC_ALPHA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

gcloud compute firewall-rules create ${VPC_BETA}-allow-internal \
    --network=$VPC_BETA \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8

echo ""
echo "Règles rétablies."
echo ""

echo "Point clé : Le peering établit la connectivité réseau, mais les règles de pare-feu contrôlent toujours le trafic autorisé."
