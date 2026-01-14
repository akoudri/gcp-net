#!/bin/bash
# Lab 5.7 - Exercice 5.7.6 : (Optionnel) Configurer DNS pour le service
# Objectif : Créer un nom DNS pour l'endpoint PSC

set -e

echo "=== Lab 5.7 - Exercice 6 : Configurer DNS pour le service (OPTIONNEL) ==="
echo ""

export VPC_CONSUMER="vpc-consumer"

echo "VPC : $VPC_CONSUMER"
echo ""

# Créer une zone DNS privée pour le service
echo "Création de la zone DNS privée..."
gcloud dns managed-zones create service-internal \
    --dns-name="service.internal." \
    --visibility=private \
    --networks=$VPC_CONSUMER

echo ""

# Enregistrement A vers l'endpoint PSC
echo "Création de l'enregistrement DNS..."
gcloud dns record-sets create "myapi.service.internal." \
    --zone=service-internal \
    --type=A \
    --ttl=300 \
    --rrdatas="10.60.0.100"

echo ""
echo "DNS configuré !"
echo ""

# Lister les enregistrements
echo "=== Enregistrements DNS ==="
gcloud dns record-sets list --zone=service-internal

echo ""

# Tester depuis la VM
echo "=== Test du DNS ==="
export ZONE="europe-west1-b"

gcloud compute ssh consumer-vm --zone=$ZONE --tunnel-through-iap --command="
echo 'Test de résolution DNS :'
nslookup myapi.service.internal
echo ''

echo 'Test d accès via le nom DNS :'
curl http://myapi.service.internal
echo ''
"

echo ""
echo "=== DNS configuré avec succès ! ==="
echo ""
echo "Le service est maintenant accessible via :"
echo "- IP directe : http://10.60.0.100"
echo "- Nom DNS : http://myapi.service.internal"
echo ""
echo "Cela permet de changer l'endpoint PSC sans modifier les applications."
