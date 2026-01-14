#!/bin/bash
# Lab 5.3 - Exercice 5.3.8 : Tester la connexion à Cloud SQL
# Objectif : Vérifier la connectivité via PSA

set -e

echo "=== Lab 5.3 - Exercice 8 : Tester la connexion à Cloud SQL ==="
echo ""

export ZONE="europe-west1-b"

# Récupérer l'IP SQL
if [ -f /tmp/sql-ip.env ]; then
    source /tmp/sql-ip.env
else
    export SQL_IP=$(gcloud sql instances describe sql-private \
        --format="get(ipAddresses[0].ipAddress)")
fi

echo "IP Cloud SQL : $SQL_IP"
echo ""

echo "Connexion à la VM pour tester Cloud SQL..."
echo "Mot de passe à entrer : MySecureP@ssw0rd!"
echo ""

# Se connecter à la VM et tester
gcloud compute ssh vm-sql-client --zone=$ZONE --tunnel-through-iap --command="
echo '=== Test 1 : Connexion à Cloud SQL ==='
PGPASSWORD='MySecureP@ssw0rd!' psql -h $SQL_IP -U postgres -d testdb -c 'SELECT version();'
echo ''

echo '=== Test 2 : Création d une table de test ==='
PGPASSWORD='MySecureP@ssw0rd!' psql -h $SQL_IP -U postgres -d testdb << 'EOSQL'
CREATE TABLE IF NOT EXISTS test_psa (
    id SERIAL PRIMARY KEY,
    message VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO test_psa (message) VALUES ('PSA fonctionne !');

SELECT * FROM test_psa;
EOSQL
echo ''
echo 'SUCCÈS: La connexion à Cloud SQL via PSA fonctionne !'
"

echo ""
echo "=== Questions à considérer ==="
echo ""
echo "1. L'IP de Cloud SQL (10.100.0.x) fait-elle partie de vos sous-réseaux ?"
echo "   → Non, elle fait partie de la plage PSA (10.100.0.0/24) qui est"
echo "     dans un VPC Google distinct, connecté via VPC Peering."
echo ""
echo "2. Pourquoi utiliser PSA plutôt qu'une IP publique pour Cloud SQL ?"
echo "   → Sécurité : pas d'exposition Internet"
echo "   → Performance : latence réduite (réseau privé Google)"
echo "   → Simplicité : pas besoin de gérer des IP publiques et SSL"
