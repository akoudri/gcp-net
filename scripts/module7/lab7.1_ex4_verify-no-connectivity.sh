#!/bin/bash
# Lab 7.1 - Exercice 7.1.4 : Vérifier l'absence de connectivité initiale
# Objectif : Confirmer qu'il n'y a pas de connectivité avant la configuration VPN

set -e

echo "=== Lab 7.1 - Exercice 4 : Vérifier l'absence de connectivité initiale ==="
echo ""

export ZONE="europe-west1-b"

# Se connecter à vm-gcp et tenter de joindre vm-onprem
echo ">>> Test de connectivité depuis vm-gcp vers vm-onprem (192.168.0.10)..."
echo "Résultat attendu : Network unreachable ou timeout"
echo ""

gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test connectivité AVANT VPN ==="
ping -c 3 -W 2 192.168.0.10 2>&1 || echo "Ping échoué (attendu)"
EOF

echo ""
echo "=== Test terminé ==="
echo "La connectivité devrait échouer car le VPN n'est pas encore configuré."
