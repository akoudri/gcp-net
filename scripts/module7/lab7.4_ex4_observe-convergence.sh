#!/bin/bash
# Lab 7.4 - Exercice 7.4.4 : Observer la convergence
# Objectif : Observer la convergence du routage après la panne

set -e

echo "=== Lab 7.4 - Exercice 4 : Observer la convergence ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Le trafic devrait maintenant passer uniquement par le tunnel 1
echo "=== Routes après panne du tunnel 0 ==="
gcloud compute routes list --filter="network:vpc-gcp AND destRange=192.168.0.0/24" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

echo ""
echo "=== Observation terminée ==="
echo ""
echo "Seule la route via tunnel-1 devrait rester."
echo "Le trafic est maintenant routé uniquement par le tunnel 1."
