#!/bin/bash
# Lab 11.2 - Exercice 11.2.5 : Générer du trafic de test
# Objectif : Générer du trafic pour tester les Flow Logs

set -e

echo "=== Lab 11.2 - Exercice 5 : Générer du trafic de test ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Génération de trafic depuis vm-source..."
echo ""

# Récupérer l'IP de vm-dest
VM_DEST_IP=$(gcloud compute instances describe vm-dest --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")
echo "IP de vm-dest : $VM_DEST_IP"
echo ""

# Se connecter à vm-source et générer du trafic
echo "Connexion à vm-source et génération de trafic..."
gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << EOF
# Trafic vers l'autre VM
echo "1. Test ping vers vm-dest..."
ping -c 5 $VM_DEST_IP

echo ""
echo "2. Test HTTP vers vm-dest..."
curl -s http://$VM_DEST_IP -o /dev/null && echo "HTTP OK"

echo ""
echo "3. Trafic vers Internet..."
curl -s https://www.google.com -o /dev/null && echo "Google OK"
curl -s https://storage.googleapis.com -o /dev/null && echo "GCS OK"

echo ""
echo "Trafic généré avec succès!"
EOF

echo ""
echo "=== Trafic généré ==="
echo ""
echo "Les Flow Logs seront disponibles dans Cloud Logging après quelques minutes."
echo ""
echo "Pour voir les logs, utilisez les scripts du Lab 11.3 ou exécutez :"
echo "  gcloud logging read 'resource.type=\"gce_subnetwork\"' --limit=10"
