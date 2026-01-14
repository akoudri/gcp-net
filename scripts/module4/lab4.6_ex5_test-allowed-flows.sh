#!/bin/bash
# Lab 4.6 - Exercice 4.6.5 : Tester les flux autorisés
# Objectif : Vérifier que les règles de pare-feu fonctionnent correctement

set -e

echo "=== Lab 4.6 - Exercice 5 : Tester les flux autorisés ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Tests des flux réseau selon les règles de pare-feu..."
echo ""

# Test: Frontend → Backend (port 8080) - Autorisé
echo "Test 1: Frontend → Backend (port 8080) - Devrait fonctionner..."
gcloud compute ssh vm-frontend --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Frontend → Backend (port 8080) ==="
sleep 30  # Attendre que le service backend démarre
curl -s --connect-timeout 5 http://10.100.1.10:8080 && echo " SUCCESS" || echo " FAILED"
EOF

echo ""

# Test: Frontend → Database (port 5432) - Refusé (pas de règle)
echo "Test 2: Frontend → Database (port 5432) - Devrait être bloqué..."
gcloud compute ssh vm-frontend --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Frontend → Database (port 5432) ==="
timeout 5 bash -c 'cat < /dev/null > /dev/tcp/10.100.2.10/5432' 2>/dev/null && echo "SUCCESS" || echo "BLOCKED (as expected)"
EOF

echo ""

# Test: Backend → Database (ping) - Autorisé (règle interne)
echo "Test 3: Backend → Database (ping) - Devrait fonctionner..."
gcloud compute ssh vm-backend --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Backend → Database (ping) ==="
ping -c 3 10.100.2.10
EOF

echo ""
echo "Tests terminés !"
echo ""

echo "Observations :"
echo "1. Frontend peut atteindre Backend sur le port 8080 (règle spécifique)"
echo "2. Frontend ne peut PAS atteindre Database directement (pas de règle)"
echo "3. Backend peut atteindre Database (règle interne)"
