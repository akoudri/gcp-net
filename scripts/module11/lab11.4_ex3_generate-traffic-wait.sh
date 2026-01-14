#!/bin/bash
# Lab 11.4 - Exercice 11.4.3 : Générer du trafic et attendre l'export
# Objectif : Générer du trafic varié pour tester l'export BigQuery

set -e

echo "=== Lab 11.4 - Exercice 3 : Générer du trafic et attendre l'export ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Génération de trafic varié depuis vm-source..."
echo ""

# Générer du trafic varié
gcloud compute ssh vm-source --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "Génération de trafic HTTP..."
for i in {1..20}; do
    curl -s http://vm-dest > /dev/null
    curl -s https://www.google.com > /dev/null
done

echo "Trafic vers différents services Google..."
curl -s https://storage.googleapis.com > /dev/null
curl -s https://bigquery.googleapis.com > /dev/null

echo "Test ping..."
ping -c 10 vm-dest

echo "Trafic généré avec succès!"
EOF

echo ""
echo "=== Trafic généré ==="
echo ""
echo "Attendre 5-10 minutes pour que les données soient exportées vers BigQuery..."
echo ""
echo "Vérifiez l'arrivée des données avec le script suivant (lab11.4_ex4)."
