#!/bin/bash
# Lab 6.2 - Exercice 6.2.1 : Découvrir le DNS interne automatique
# Objectif : Explorer le DNS automatique de GCP

set -e

echo "=== Lab 6.2 - Exercice 1 : Découvrir le DNS interne automatique ==="
echo ""

# Variables
export ZONE="europe-west1-b"
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo "Zone : $ZONE"
echo ""

echo "Connexion à VM1 pour tester le DNS automatique..."
echo ""

# Se connecter à vm1 et tester
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << EOF
echo "=== Test du nom DNS automatique (format zonal) ==="
echo "Format: [VM_NAME].[ZONE].c.[PROJECT_ID].internal"
echo ""
nslookup vm2.${ZONE}.c.${PROJECT_ID}.internal
echo ""

echo "=== Test avec ping ==="
ping -c 3 vm2.${ZONE}.c.${PROJECT_ID}.internal
echo ""

echo "=== Test du nom court ==="
echo "Tentative de ping avec le nom court (peut fonctionner selon la config)..."
ping -c 3 vm2 2>/dev/null || echo "Le nom court ne fonctionne pas, ce qui est normal."
echo ""
EOF

echo ""
echo "Tests terminés !"
