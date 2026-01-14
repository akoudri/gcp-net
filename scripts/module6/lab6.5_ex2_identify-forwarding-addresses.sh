#!/bin/bash
# Lab 6.5 - Exercice 6.5.2 : Identifier les adresses de forwarding
# Objectif : Récupérer l'adresse IP de l'inbound forwarder

set -e

echo "=== Lab 6.5 - Exercice 2 : Identifier les adresses de forwarding ==="
echo ""

echo "Les adresses de forwarding sont créées automatiquement dans chaque sous-réseau."
echo "Elles permettent aux clients externes de résoudre via Cloud DNS."
echo ""

# Récupérer l'adresse de forwarding
export INBOUND_IP=$(gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER AND subnetwork~subnet-dns" \
    --format="get(address)")

echo "Adresse Inbound Forwarder : $INBOUND_IP"
echo ""

if [ -z "$INBOUND_IP" ]; then
    echo "⚠️  Aucune adresse trouvée. Vérifiez que la politique DNS est bien créée."
    echo "Il peut falloir quelques minutes pour que les adresses soient créées."
else
    echo "✓ Adresse de forwarding identifiée avec succès !"
    echo ""
    echo "Utilisez cette adresse dans les prochains exercices pour tester l'inbound forwarding."
fi
echo ""

echo "=== Liste complète des adresses DNS Resolver ==="
gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER" \
    --format="table(name,address,region,subnetwork)"
