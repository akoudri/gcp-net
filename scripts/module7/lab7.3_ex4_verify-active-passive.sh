#!/bin/bash
# Lab 7.3 - Exercice 7.3.4 : Vérifier la configuration Actif/Passif
# Objectif : Vérifier que le mode Actif/Passif est bien configuré

set -e

echo "=== Lab 7.3 - Exercice 4 : Vérifier la configuration Actif/Passif ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Attendre la convergence BGP
echo ">>> Attente de la convergence BGP (30 secondes)..."
sleep 30

echo ""

# Voir les routes avec leurs priorités
echo "=== Routes après configuration Actif/Passif ==="
gcloud compute routes list --filter="network:vpc-gcp AND destRange=192.168.0.0/24" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

echo ""
echo "=== Vérification terminée ==="
echo ""
echo "La route via tunnel-0 devrait avoir priorité 100"
echo "La route via tunnel-1 devrait avoir priorité 200"
echo "Tout le trafic passe par tunnel-0 (priorité 100)"
