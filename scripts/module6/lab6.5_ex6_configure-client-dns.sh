#!/bin/bash
# Lab 6.5 - Exercice 6.5.6 : Configurer le client pour utiliser l'inbound forwarder
# Objectif : Modifier la configuration DNS du client on-premise

set -e

echo "=== Lab 6.5 - Exercice 6 : Configurer le client pour utiliser l'inbound forwarder ==="
echo ""

export ZONE="europe-west1-b"

# Récupérer l'adresse de forwarding
export INBOUND_IP=$(gcloud compute addresses list \
    --filter="purpose=DNS_RESOLVER AND subnetwork~subnet-dns" \
    --format="get(address)")

if [ -z "$INBOUND_IP" ]; then
    echo "⚠️  Impossible de trouver l'adresse inbound forwarder."
    exit 1
fi

echo "Adresse Inbound Forwarder : $INBOUND_IP"
echo ""

echo "Configuration du client on-premise pour utiliser l'inbound forwarder..."
echo ""

# Sur le client on-premise, configurer le DNS
gcloud compute ssh client-onprem --zone=$ZONE --tunnel-through-iap << EOF
echo "=== Configuration DNS du client ==="

# Modifier resolv.conf (temporaire)
echo "Modification de /etc/resolv.conf..."
sudo bash -c 'echo "nameserver ${INBOUND_IP}" > /etc/resolv.conf'
echo ""

echo "Configuration DNS mise à jour !"
echo ""

# Vérifier la configuration
echo "=== Configuration DNS actuelle ==="
cat /etc/resolv.conf
echo ""

# Maintenant les requêtes passent par Cloud DNS
echo "=== Test de résolution ==="
echo "Test pour vm1.lab.internal :"
nslookup vm1.lab.internal
echo ""

echo "Test pour vm2.lab.internal :"
nslookup vm2.lab.internal
echo ""
EOF

echo ""
echo "Configuration terminée !"
echo ""
echo "Note : Dans un vrai scénario on-premise, vous configureriez vos serveurs DNS"
echo "on-premise pour transférer les requêtes vers ces adresses via VPN/Interconnect."
