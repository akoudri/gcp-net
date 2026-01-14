#!/bin/bash
# Lab 6.4 - Exercice 6.4.6 : Tester le forwarding depuis une VM cliente
# Objectif : Vérifier que le forwarding DNS fonctionne

set -e

echo "=== Lab 6.4 - Exercice 6 : Tester le forwarding depuis une VM cliente ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à VM1 pour tester le forwarding DNS..."
echo ""

# Se connecter à vm1 (client)
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test forwarding DNS ==="

echo "Test de résolution pour server.corp.local :"
nslookup server.corp.local
echo ""

echo "Test de résolution pour db.corp.local :"
dig db.corp.local +short
echo ""

echo "Test de résolution pour app.corp.local :"
dig app.corp.local +short
echo ""

# Vérifier que les autres zones fonctionnent toujours
echo "=== Test zone privée ==="
echo "Test de résolution pour vm2.lab.internal :"
nslookup vm2.lab.internal
echo ""
EOF

echo ""
echo "Tests de forwarding terminés !"
echo ""
echo "Questions à considérer :"
echo "1. Pourquoi le forwarding utilise-t-il le routage privé pour les IPs RFC 1918 ?"
echo "2. Que se passe-t-il si le serveur DNS cible est injoignable ?"
