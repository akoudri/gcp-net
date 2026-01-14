#!/bin/bash
# Lab 7.3 - Exercice 7.3.1 : Vérifier le mode actuel (Actif/Actif par défaut)
# Objectif : Vérifier que le mode Actif/Actif (ECMP) est configuré par défaut

set -e

echo "=== Lab 7.3 - Exercice 1 : Vérifier le mode Actif/Actif ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Par défaut, les deux tunnels ont la même priorité
echo "=== Routes via VPN (mode Actif/Actif) ==="
gcloud compute routes list --filter="network:vpc-gcp AND nextHopVpnTunnel~tunnel" \
    --format="table(name,destRange,nextHopVpnTunnel,priority)"

echo ""
echo "=== Vérification terminée ==="
echo ""
echo "Les deux tunnels devraient apparaître avec la même priorité (1000)."
echo "Le trafic est réparti via ECMP (Equal Cost Multi-Path)."
