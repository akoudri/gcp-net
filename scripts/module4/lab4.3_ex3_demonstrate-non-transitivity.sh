#!/bin/bash
# Lab 4.3 - Exercice 4.3.3 : Démontrer la non-transitivité
# Objectif : Prouver que le peering n'est pas transitif

set -e

echo "=== Lab 4.3 - Exercice 3 : Démontrer la non-transitivité ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Tests de connectivité pour démontrer la non-transitivité..."
echo ""

# Tester la connectivité Alpha → Beta (fonctionne)
echo "Test 1: Alpha → Beta (devrait fonctionner)..."
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Alpha → Beta ==="
ping -c 3 10.20.1.10 && echo "SUCCESS" || echo "FAILED"
EOF

echo ""

# Tester la connectivité Beta → Gamma (fonctionne)
echo "Test 2: Beta → Gamma (devrait fonctionner)..."
gcloud compute ssh vm-beta --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Beta → Gamma ==="
ping -c 3 10.30.1.10 && echo "SUCCESS" || echo "FAILED"
EOF

echo ""

# Tester la connectivité Alpha → Gamma (ÉCHOUE - non transitif)
echo "Test 3: Alpha → Gamma via Beta (devrait ÉCHOUER)..."
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Alpha → Gamma (via Beta) ==="
ping -c 3 10.30.1.10 && echo "SUCCESS" || echo "FAILED - NON TRANSITIF"
EOF

echo ""
echo "Conclusion :"
echo "Le VPC Peering n'est PAS transitif."
echo "Bien que Alpha↔Beta et Beta↔Gamma soient peerés,"
echo "Alpha ne peut pas atteindre Gamma à travers Beta."
echo ""

echo "Question : Pourquoi Alpha ne peut-il pas atteindre Gamma alors que Alpha↔Beta et Beta↔Gamma sont peerés ?"
