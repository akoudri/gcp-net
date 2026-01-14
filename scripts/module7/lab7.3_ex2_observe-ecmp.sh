#!/bin/bash
# Lab 7.3 - Exercice 7.3.2 : Observer la répartition de charge ECMP
# Objectif : Observer la répartition de charge entre les tunnels

set -e

echo "=== Lab 7.3 - Exercice 2 : Observer la répartition de charge ECMP ==="
echo ""

export ZONE="europe-west1-b"

# Se connecter à vm-gcp et envoyer du trafic
echo ">>> Test de répartition ECMP depuis vm-gcp..."
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test répartition ECMP ==="
echo "Envoi de 20 pings, observer si les deux tunnels sont utilisés..."

for i in {1..20}; do
    ping -c 1 -W 1 192.168.0.10 > /dev/null 2>&1
done

echo "Pour observer la répartition, vérifier les métriques des tunnels dans la console GCP"
echo "Monitoring > Metrics Explorer > vpn.googleapis.com/tunnel/sent_bytes_count"
EOF

echo ""
echo "=== Test terminé ==="
