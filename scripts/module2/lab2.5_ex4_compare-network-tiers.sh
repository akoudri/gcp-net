#!/bin/bash
# Lab 2.5 - Exercice 2.5.4 : Comparer les performances des Network Tiers
# Objectif : Mesurer la latence et analyser le routage

set -e

echo "=== Lab 2.5 - Exercice 4 : Comparer les performances ==="
echo ""

# Récupérer les IPs
export IP_PREMIUM=$(gcloud compute instances describe vm-premium \
    --zone=europe-west1-b \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

export IP_STANDARD=$(gcloud compute addresses describe ip-standard \
    --region=europe-west1 \
    --format="get(address)")

echo "IP Premium : $IP_PREMIUM"
echo "IP Standard : $IP_STANDARD"
echo ""

# Test de latence vers Premium
echo "=== Test Premium Tier ==="
ping -c 20 $IP_PREMIUM | tail -1

echo ""

# Test de latence vers Standard
echo "=== Test Standard Tier ==="
ping -c 20 $IP_STANDARD | tail -1

echo ""
echo "=== Traceroute vers Premium ==="
traceroute $IP_PREMIUM

echo ""
echo "=== Traceroute vers Standard ==="
traceroute $IP_STANDARD

echo ""
echo "Questions à considérer :"
echo "1. Quelle est la différence de latence moyenne observée ?"
echo "2. Les chemins réseau sont-ils différents ?"
echo "3. À quel moment le trafic entre sur le réseau Google pour chaque tier ?"
echo ""
echo "Note : Premium entre sur le réseau Google au PoP le plus proche."
echo "       Standard entre au niveau de la région GCP."
