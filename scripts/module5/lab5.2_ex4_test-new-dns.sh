#!/bin/bash
# Lab 5.2 - Exercice 5.2.4 : Tester la nouvelle résolution DNS
# Objectif : Vérifier que le DNS pointe maintenant vers les IPs VIP privées

set -e

echo "=== Lab 5.2 - Exercice 4 : Tester la nouvelle résolution DNS ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM pour tester la résolution DNS..."
echo ""
echo "IMPORTANT: Le DNS peut prendre quelques minutes pour se propager."
echo ""

# Tests de résolution DNS dans la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap --command="
echo '=== Test 1 : Résolution DNS avec nslookup ==='
nslookup storage.googleapis.com
echo ''

echo '=== Test 2 : Résolution DNS avec dig ==='
dig storage.googleapis.com +short
echo ''
echo 'Les IPs devraient maintenant être 199.36.153.x (IPs VIP privées)'
echo ''

echo '=== Test 3 : Vérifier que Cloud Storage fonctionne toujours ==='
gsutil ls gs://gcp-public-data-landsat | head -3
echo 'SUCCÈS: Cloud Storage est toujours accessible'
echo ''
"

echo ""
echo "=== Questions à considérer ==="
echo ""
echo "1. Quelle est la différence entre les IPs Anycast publiques et 199.36.153.x ?"
echo "   → Les IPs VIP privées (199.36.153.x) sont dédiées à PGA et"
echo "     ne sont accessibles que depuis les VPCs avec PGA activé."
echo ""
echo "2. Pourquoi configurer le DNS ainsi améliore-t-il la sécurité ?"
echo "   → Cela garantit que le trafic passe par PGA et non par Internet,"
echo "     même si des routes Internet existent."
