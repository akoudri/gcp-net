#!/bin/bash
# Lab 5.2 - Exercice 5.2.1 : Vérifier la résolution DNS par défaut
# Objectif : Observer comment googleapis.com est résolu par défaut

set -e

echo "=== Lab 5.2 - Exercice 1 : Vérifier la résolution DNS par défaut ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM pour vérifier la résolution DNS..."
echo ""

# Tests de résolution DNS dans la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap --command="
echo '=== Résolution DNS avec nslookup ==='
nslookup storage.googleapis.com
echo ''

echo '=== Résolution DNS avec dig ==='
dig storage.googleapis.com +short
echo ''

echo 'Les IPs retournées sont des IPs publiques Google Anycast'
echo 'Exemple: 142.250.x.x, 172.217.x.x (varie selon votre localisation)'
echo ''
"

echo ""
echo "=== Observations ==="
echo ""
echo "Par défaut, googleapis.com se résout vers des IPs publiques Anycast."
echo "Ces IPs sont accessibles via Internet ET via PGA."
echo ""
echo "Dans le prochain exercice, nous configurerons le DNS pour forcer"
echo "l'utilisation des IPs VIP privées de Google (199.36.153.x)."
