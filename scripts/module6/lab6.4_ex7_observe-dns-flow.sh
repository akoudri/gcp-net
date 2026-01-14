#!/bin/bash
# Lab 6.4 - Exercice 6.4.7 : Observer le flux DNS
# Objectif : Surveiller les requêtes DNS reçues par le serveur

set -e

echo "=== Lab 6.4 - Exercice 7 : Observer le flux DNS ==="
echo ""

export ZONE="europe-west1-b"

echo "Observation des logs DNS en temps réel sur le serveur DNS..."
echo ""
echo "Instructions :"
echo "1. Les logs s'afficheront en temps réel"
echo "2. Dans un autre terminal, exécutez lab6.4_ex6_test-forwarding.sh"
echo "3. Vous verrez les requêtes apparaître dans les logs"
echo "4. Appuyez sur Ctrl+C pour arrêter l'observation"
echo ""
echo "Démarrage dans 5 secondes..."
sleep 5
echo ""

# Sur le serveur DNS, observer les requêtes reçues
gcloud compute ssh dns-server --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Logs DNS en temps réel ==="
echo "Observation des logs dnsmasq..."
echo ""
sudo tail -f /var/log/dnsmasq.log
EOF
