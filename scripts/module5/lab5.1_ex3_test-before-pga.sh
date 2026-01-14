#!/bin/bash
# Lab 5.1 - Exercice 5.1.3 : Tester AVANT l'activation de PGA
# Objectif : Démontrer que l'accès aux APIs Google échoue sans PGA

set -e

echo "=== Lab 5.1 - Exercice 3 : Tester AVANT l'activation de PGA ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM pour effectuer les tests..."
echo ""
echo "Les tests suivants vont être exécutés :"
echo "1. Test d'accès à Cloud Storage (devrait échouer)"
echo "2. Test de résolution DNS (devrait fonctionner)"
echo "3. Test de connectivité HTTPS vers APIs (devrait échouer)"
echo ""
echo "Exécution des tests..."
echo ""

# Tests à exécuter dans la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap --command="
echo '=== Test 1 : Accès à Cloud Storage ==='
timeout 10 gsutil ls gs://gcp-public-data-landsat 2>&1 | head -5 || echo 'ERREUR: Impossible d'accéder à Cloud Storage (attendu)'
echo ''

echo '=== Test 2 : Résolution DNS ==='
nslookup storage.googleapis.com | head -10
echo ''

echo '=== Test 3 : Connectivité HTTPS vers APIs ==='
timeout 10 curl -v --connect-timeout 10 https://storage.googleapis.com 2>&1 | head -20 || echo 'ERREUR: Timeout (attendu - pas de route vers Internet)'
echo ''
"

echo ""
echo "=== Résumé des tests ==="
echo ""
echo "Questions à considérer :"
echo "1. Pourquoi la résolution DNS fonctionne-t-elle malgré l'absence d'IP externe ?"
echo "2. Pourquoi la connexion HTTPS échoue-t-elle ?"
echo ""
echo "Réponses :"
echo "1. Le DNS passe par le metadata server (169.254.169.254) qui est toujours accessible"
echo "2. Sans PGA, il n'y a pas de route pour atteindre les IPs publiques des APIs Google"
