#!/bin/bash
# Lab 5.4 - Exercice 5.4.3 : Tester la connexion Redis
# Objectif : Vérifier la connectivité à Memorystore via PSA

set -e

echo "=== Lab 5.4 - Exercice 3 : Tester la connexion Redis ==="
echo ""

export ZONE="europe-west1-b"

# Récupérer l'IP Redis
if [ -f /tmp/redis-ip.env ]; then
    source /tmp/redis-ip.env
else
    export REDIS_IP=$(gcloud redis instances describe redis-private \
        --region=europe-west1 \
        --format="get(host)")
fi

echo "IP Redis : $REDIS_IP"
echo ""

echo "Connexion à la VM pour tester Redis..."
echo ""

# Se connecter à la VM et tester Redis
gcloud compute ssh vm-sql-client --zone=$ZONE --tunnel-through-iap --command="
# Installer redis-tools si pas déjà fait
sudo apt-get update -qq
sudo apt-get install -y redis-tools

echo '=== Test 1 : Ping Redis ==='
redis-cli -h $REDIS_IP ping
echo ''

echo '=== Test 2 : Commandes Redis ==='
redis-cli -h $REDIS_IP << 'EOCLI'
SET test:psa \"Memorystore fonctionne!\"
GET test:psa
KEYS *
INFO server
EOCLI
echo ''
echo 'SUCCÈS: Memorystore Redis est accessible via PSA !'
"

echo ""
echo "=== Redis testé avec succès ! ==="
echo ""
echo "Cloud SQL et Redis partagent la même connexion PSA"
echo "mais ont des IPs différentes dans la plage réservée (10.100.0.0/24)."
