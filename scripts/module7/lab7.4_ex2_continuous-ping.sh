#!/bin/bash
# Lab 7.4 - Exercice 7.4.2 : Lancer un ping continu
# Objectif : Lancer un ping continu pour observer les pertes pendant le failover

set -e

echo "=== Lab 7.4 - Exercice 2 : Lancer un ping continu ==="
echo ""

export ZONE="europe-west1-b"

echo "Zone : $ZONE"
echo ""

cat << 'INFO'
Ce script va lancer un ping continu depuis vm-gcp vers vm-onprem.
Gardez ce terminal ouvert pour observer les pertes de paquets pendant le failover.

Pour simuler une panne, exécutez lab7.4_ex3_simulate-failure.sh dans un autre terminal.

INFO

# Se connecter à vm-gcp et lancer un ping continu
echo ">>> Connexion à vm-gcp et lancement du ping continu..."
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap -- ping 192.168.0.10
