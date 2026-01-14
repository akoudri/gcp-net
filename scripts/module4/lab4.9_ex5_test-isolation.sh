#!/bin/bash
# Lab 4.9 - Exercice 4.9.5 : Tester l'isolation
# Objectif : Vérifier que l'isolation fonctionne correctement

set -e

echo "=== Lab 4.9 - Exercice 5 : Tester l'isolation ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Tests d'isolation entre les environnements..."
echo ""

# Partenaire → Prod (devrait fonctionner)
echo "Test 1: Partenaire → Prod (devrait fonctionner)..."
gcloud compute ssh vm-partner --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Partenaire → Prod ==="
ping -c 3 10.10.0.10 && echo "SUCCESS" || echo "BLOCKED"
EOF

echo ""

# Partenaire → Dev (devrait être bloqué)
echo "Test 2: Partenaire → Dev (devrait être bloqué)..."
gcloud compute ssh vm-partner --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Partenaire → Dev ==="
ping -c 3 10.30.0.10 && echo "SUCCESS" || echo "BLOCKED (expected)"
EOF

echo ""

# Interne: Prod → Dev (devrait fonctionner)
echo "Test 3: Prod → Dev (interne, devrait fonctionner)..."
gcloud compute ssh vm-prod --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Prod → Dev (interne) ==="
ping -c 3 10.30.0.10 && echo "SUCCESS" || echo "BLOCKED"
EOF

echo ""
echo "Tests d'isolation terminés !"
echo ""

echo "Observations :"
echo "1. Le partenaire peut accéder à la production (autorisé)"
echo "2. Le partenaire ne peut PAS accéder au dev/staging (bloqué)"
echo "3. Les environnements internes peuvent communiquer entre eux"
