#!/bin/bash
# Lab 8.2 - Exercice 8.2.7 : Tester les règles
# Objectif : Vérifier le fonctionnement des règles de pare-feu

set -e

echo "=== Lab 8.2 - Exercice 7 : Tester les règles de pare-feu ==="
echo ""

export ZONE="europe-west1-b"

echo "Zone : $ZONE"
echo ""

echo ">>> Test des règles de pare-feu depuis vm-web..."
echo ""

# Note : Les tests ci-dessous supposent que vm-api est à 10.0.2.3 et vm-db à 10.0.2.4
# En pratique, vérifiez les IPs réelles avec : gcloud compute instances list

gcloud compute ssh vm-web --zone=$ZONE --command="
echo '=== Test depuis vm-web ==='
echo ''

# Test vers vm-api (devrait fonctionner)
echo 'Test connexion vers vm-api:8080...'
VM_API_IP=\$(gcloud compute instances describe vm-api --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
nc -zv \$VM_API_IP 8080 -w 3 2>&1 || echo 'Port 8080 non accessible (attendu si pas de service)'
echo ''

# Test vers vm-db (devrait échouer - pas autorisé directement)
echo 'Test connexion vers vm-db:5432...'
VM_DB_IP=\$(gcloud compute instances describe vm-db --zone=$ZONE --format='get(networkInterfaces[0].networkIP)')
nc -zv \$VM_DB_IP 5432 -w 3 2>&1 || echo 'Port 5432 non accessible (attendu - règle de pare-feu)'
echo ''

# Test ICMP
echo 'Test ping vers vm-api...'
ping -c 2 \$VM_API_IP
echo ''

echo 'Tests terminés !'
"

echo ""
echo "=== Interprétation des résultats ==="
echo ""
echo "1. La connexion vers vm-api:8080 devrait être autorisée (règle web → api)"
echo "2. La connexion vers vm-db:5432 devrait être bloquée (pas de règle web → db)"
echo "3. Le ping vers vm-api devrait fonctionner (règle ICMP interne)"
echo ""

echo "Questions à considérer :"
echo "1. Comment vérifier quelle règle a été appliquée pour chaque connexion ?"
echo "2. Que se passerait-il si on supprimait la règle allow-icmp-internal ?"
echo "3. Comment débugger une connexion bloquée de manière inattendue ?"
