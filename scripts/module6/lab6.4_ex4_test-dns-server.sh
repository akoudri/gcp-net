#!/bin/bash
# Lab 6.4 - Exercice 6.4.4 : Tester le serveur DNS directement
# Objectif : Vérifier que le serveur DNS fonctionne correctement

set -e

echo "=== Lab 6.4 - Exercice 4 : Tester le serveur DNS directement ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion au serveur DNS pour vérifier sa configuration..."
echo ""

# Se connecter au serveur DNS pour vérifier
gcloud compute ssh dns-server --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test local du serveur DNS ==="

# Tester localement
echo "Test de résolution pour server.corp.local :"
dig @127.0.0.1 server.corp.local +short
echo ""

echo "Test de résolution pour db.corp.local :"
dig @127.0.0.1 db.corp.local +short
echo ""

echo "Test de résolution pour app.corp.local :"
dig @127.0.0.1 app.corp.local +short
echo ""

# Voir les logs (dernières lignes)
echo "=== Derniers logs dnsmasq ==="
sudo tail -20 /var/log/dnsmasq.log
echo ""

# Tester une requête et voir le log
echo "=== Test d'une requête ==="
dig @127.0.0.1 app.corp.local
echo ""
EOF

echo ""
echo "Tests terminés !"
