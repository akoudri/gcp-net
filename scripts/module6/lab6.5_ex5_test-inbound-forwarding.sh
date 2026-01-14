#!/bin/bash
# Lab 6.5 - Exercice 6.5.5 : Tester l'inbound forwarding
# Objectif : Vérifier que l'inbound forwarding fonctionne

set -e

echo "=== Lab 6.5 - Exercice 5 : Tester l'inbound forwarding ==="
echo ""

export ZONE="europe-west1-b"
export PROJECT_ID=$(gcloud config get-value project)

# Récupérer l'adresse de forwarding
export INBOUND_IP=$(gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER AND subnetwork~subnet-dns" \
    --format="get(address)")

if [ -z "$INBOUND_IP" ]; then
    echo "⚠️  Impossible de trouver l'adresse inbound forwarder."
    echo "Assurez-vous que la politique DNS est créée et attendez quelques minutes."
    exit 1
fi

echo "Adresse Inbound Forwarder : $INBOUND_IP"
echo ""

echo "Connexion au client on-premise pour tester l'inbound forwarding..."
echo ""

# Se connecter au client on-premise
gcloud compute ssh client-onprem --zone=$ZONE --tunnel-through-iap << EOF
echo "=== Test de l'inbound forwarding ==="

echo "Par défaut, le client utilise le DNS metadata (169.254.169.254)"
echo "Nous allons tester en spécifiant l'inbound forwarder explicitement."
echo ""

# Tester les résolutions via l'inbound forwarder
echo "Test de résolution pour vm1.lab.internal :"
dig @${INBOUND_IP} vm1.lab.internal +short
echo ""

echo "Test de résolution pour vm2.lab.internal :"
dig @${INBOUND_IP} vm2.lab.internal +short
echo ""

echo "Test de résolution pour db.lab.internal :"
dig @${INBOUND_IP} db.lab.internal +short
echo ""

# Tester aussi le DNS automatique GCP
echo "Test de résolution pour le DNS automatique GCP :"
dig @${INBOUND_IP} vm1.${ZONE}.c.${PROJECT_ID}.internal +short
echo ""
EOF

echo ""
echo "Tests d'inbound forwarding terminés !"
