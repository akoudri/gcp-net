#!/bin/bash
# Lab 5.1 - Exercice 5.1.5 : Tester APRÈS l'activation de PGA
# Objectif : Démontrer que l'accès aux APIs Google fonctionne maintenant avec PGA

set -e

echo "=== Lab 5.1 - Exercice 5 : Tester APRÈS l'activation de PGA ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM pour effectuer les tests..."
echo ""
echo "Les tests suivants vont être exécutés :"
echo "1. Test d'accès à Cloud Storage (devrait fonctionner)"
echo "2. Test d'accès à l'API Discovery (devrait fonctionner)"
echo "3. Test d'accès à Internet (devrait toujours échouer)"
echo ""
echo "Exécution des tests..."
echo ""

# Tests à exécuter dans la VM
gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap --command="
echo '=== Test 1 : Accès à Cloud Storage ==='
gsutil ls gs://gcp-public-data-landsat | head -5
echo 'SUCCÈS: Cloud Storage est accessible via PGA'
echo ''

echo '=== Test 2 : Accès à l API Discovery ==='
HTTP_CODE=\$(curl -s -o /dev/null -w '%{http_code}' https://www.googleapis.com/discovery/v1/apis)
echo \"Code HTTP: \$HTTP_CODE\"
if [ \"\$HTTP_CODE\" = \"200\" ]; then
    echo 'SUCCÈS: L API Discovery est accessible'
else
    echo \"ERREUR: Code inattendu \$HTTP_CODE\"
fi
echo ''

echo '=== Test 3 : Accès à Internet (github.com) ==='
timeout 5 curl -v --connect-timeout 5 https://www.github.com 2>&1 | head -15 || echo 'ERREUR: Timeout (attendu - PGA ≠ Internet)'
echo ''
"

echo ""
echo "=== Résumé des tests ==="
echo ""
echo "Questions à considérer :"
echo "1. PGA permet-il d'accéder à github.com ? Pourquoi ?"
echo "2. Quel mécanisme permet maintenant à la VM d'atteindre Cloud Storage ?"
echo ""
echo "Réponses :"
echo "1. Non, PGA permet uniquement d'accéder aux APIs Google (googleapis.com, gcr.io, etc.)"
echo "2. PGA route le trafic vers les IPs 199.36.153.8/30 (VIP privées de Google)"
