#!/bin/bash
# Lab 4.1 - Exercice 4.1.6 : Tester APRÈS le peering
# Objectif : Vérifier que la connectivité fonctionne après le peering

set -e

echo "=== Lab 4.1 - Exercice 6 : Tester APRÈS le peering ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Test de connectivité APRÈS le peering..."
echo ""

# Tester depuis vm-alpha vers vm-beta
echo "Test 1: Ping depuis vm-alpha vers vm-beta..."
echo ""

gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test ping vers vm-beta (10.20.1.10) ==="
ping -c 5 10.20.1.10

echo ""
echo "=== Traceroute vers vm-beta ==="
traceroute -n 10.20.1.10
EOF

echo ""

# Tester dans l'autre sens (depuis vm-beta vers vm-alpha)
echo "Test 2: Ping depuis vm-beta vers vm-alpha..."
echo ""

gcloud compute ssh vm-beta --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test ping vers vm-alpha (10.10.1.10) ==="
ping -c 5 10.10.1.10

echo ""
echo "=== Traceroute vers vm-alpha ==="
traceroute -n 10.10.1.10
EOF

echo ""
echo "Tests de connectivité terminés avec succès !"
echo ""

echo "Questions à considérer :"
echo "1. Combien de sauts montre le traceroute ?"
echo "2. Le trafic passe-t-il par Internet ?"
echo "3. Quelle est la latence entre les deux VMs ?"
