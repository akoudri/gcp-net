#!/bin/bash
# Lab 11.6 - Exercice 11.6.5 : Tester le Packet Mirroring
# Objectif : Vérifier que le mirroring fonctionne

set -e

echo "=== Lab 11.6 - Exercice 5 : Tester le Packet Mirroring ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Ce script va :"
echo "  1. Démarrer une capture sur le collecteur"
echo "  2. Générer du trafic depuis vm-source"
echo ""
echo "Note: Exécutez cette capture dans un terminal séparé pour voir les packets en temps réel."
echo ""

echo "Pour démarrer la capture manuellement, exécutez :"
echo ""
echo "  gcloud compute ssh vm-collector --zone=$ZONE --tunnel-through-iap"
echo "  sudo tcpdump -i any port 4789 -nn -c 20"
echo ""

echo "Ensuite, dans un autre terminal, générez du trafic :"
echo ""
echo "  gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap"
echo "  ping -c 5 vm-dest"
echo "  curl http://vm-dest"
echo ""

read -p "Voulez-vous générer du trafic maintenant ? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Génération de trafic..."
    gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << 'EOF'
ping -c 5 vm-dest
curl -s http://vm-dest -o /dev/null && echo "HTTP OK"
echo "Trafic généré!"
EOF

    echo ""
    echo "Vérifiez la capture sur vm-collector pour voir les packets mirrorés."
fi

echo ""
echo "Test terminé."
