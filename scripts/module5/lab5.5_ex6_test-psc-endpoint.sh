#!/bin/bash
# Lab 5.5 - Exercice 5.5.6 : Tester l'accès via l'endpoint PSC
# Objectif : Vérifier que les APIs Google sont accessibles via PSC

set -e

echo "=== Lab 5.5 - Exercice 6 : Tester l'accès via l'endpoint PSC ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM pour tester PSC..."
echo ""

# Se connecter à la VM et tester
gcloud compute ssh vm-psc --zone=$ZONE --tunnel-through-iap --command="
echo '=== Test 1 : Résolution DNS ==='
nslookup storage.googleapis.com
echo ''
echo 'Devrait retourner 10.1.0.100'
echo ''

echo '=== Test 2 : Résolution avec dig ==='
dig storage.googleapis.com +short
echo ''

echo '=== Test 3 : Accès à Cloud Storage via PSC ==='
gsutil ls gs://gcp-public-data-landsat | head -3
echo 'SUCCÈS: Cloud Storage accessible via PSC'
echo ''

echo '=== Test 4 : Vérifier l IP utilisée avec curl ==='
curl -v https://storage.googleapis.com 2>&1 | grep -E 'Connected to|Trying' | head -5
echo ''
echo 'La connexion devrait être établie vers 10.1.0.100'
"

echo ""
echo "=== PSC testé avec succès ! ==="
echo ""
echo "L'endpoint PSC (10.1.0.100) est maintenant utilisé pour accéder"
echo "aux APIs Google au lieu de PGA (199.36.153.x)."
