#!/bin/bash
# Lab 4.1 - Exercice 4.1.3 : Tester AVANT le peering
# Objectif : Vérifier que la connectivité n'existe pas avant le peering

set -e

echo "=== Lab 4.1 - Exercice 3 : Tester AVANT le peering ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Test de connectivité AVANT le peering..."
echo ""

# Tester depuis vm-alpha vers vm-beta
echo "Tentative de ping depuis vm-alpha vers vm-beta (devrait échouer)..."
echo ""

gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test ping vers vm-beta (10.20.1.10) ==="
ping -c 3 10.20.1.10 && echo "SUCCESS" || echo "FAILED (attendu - pas de peering)"
EOF

echo ""
echo "Questions à considérer :"
echo "1. Pourquoi le ping échoue-t-il ?"
echo "2. Quel message d'erreur apparaît ?"
echo "3. Est-ce un problème de pare-feu ou de routage ?"
