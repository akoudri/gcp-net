#!/bin/bash
# Lab 3.9 - Exercice 3.9.2 : Tests de validation de l'architecture hybride
# Objectif : Valider que tous les composants fonctionnent correctement

set -e

export ZONE="europe-west1-b"

echo "=== Lab 3.9 - Tests de validation de l'architecture hybride ==="
echo ""

echo "Pour valider l'architecture, exécutez les tests suivants :"
echo ""

echo "=== Test 1 : Résolution DNS ==="
echo "Connectez-vous à web-vm :"
echo ""
echo "  gcloud compute ssh web-vm --zone=$ZONE --tunnel-through-iap << 'EOF'"
echo "  echo \"=== Test DNS ===\""
echo "  dig web.app.internal +short"
echo "  dig api.app.internal +short"
echo "  dig db.app.internal +short"
echo "  EOF"
echo ""

echo "=== Test 2 : Connectivité interne ==="
echo "Depuis web-vm :"
echo ""
echo "  gcloud compute ssh web-vm --zone=$ZONE --tunnel-through-iap << 'EOF'"
echo "  echo \"=== Test connectivité API ===\""
echo "  curl -s http://api.app.internal:8080"
echo "  echo \"\""
echo "  echo \"=== Ping DB ===\""
echo "  ping -c 3 db.app.internal"
echo "  EOF"
echo ""

echo "=== Test 3 : Cloud NAT fonctionne ==="
echo "Depuis api-vm :"
echo ""
echo "  gcloud compute ssh api-vm --zone=$ZONE --tunnel-through-iap << 'EOF'"
echo "  echo \"=== Test accès Internet via NAT ===\""
echo "  curl -s https://api.ipify.org && echo \" (IP NAT)\""
echo "  EOF"
echo ""

echo "=== Test 4 : Route via proxy pour db-vm ==="
echo ""
echo "Terminal 1 - Capturer sur proxy :"
echo "  gcloud compute ssh proxy-vm --zone=$ZONE --tunnel-through-iap << 'EOF'"
echo "  echo \"Démarrage capture (Ctrl+C pour arrêter)...\""
echo "  sudo tcpdump -i ens4 host 10.20.0.20 -n"
echo "  EOF"
echo ""
echo "Terminal 2 - Générer du trafic depuis db-vm :"
echo "  gcloud compute ssh db-vm --zone=$ZONE --tunnel-through-iap << 'EOF'"
echo "  curl -s https://www.google.com > /dev/null && echo \"OK via proxy\""
echo "  EOF"
echo ""

echo "=== Test 5 : Private Google Access ==="
echo "Depuis api-vm :"
echo ""
echo "  gcloud compute ssh api-vm --zone=$ZONE --tunnel-through-iap << 'EOF'"
echo "  echo \"=== Test Private Google Access ===\""
echo "  gsutil ls gs://gcp-public-data-landsat | head -3"
echo "  EOF"
echo ""

echo "Note : Ce script affiche les instructions de test."
echo "       Exécutez chaque test manuellement pour valider l'architecture."
echo ""
