#!/bin/bash
# Lab 6.7 - Exercice 6.7.2 : Générer du trafic DNS
# Objectif : Générer des requêtes DNS pour analyser les logs

set -e

echo "=== Lab 6.7 - Exercice 2 : Générer du trafic DNS ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à VM1 pour générer du trafic DNS..."
echo ""

# Se connecter à vm1 et générer des requêtes DNS
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Génération de trafic DNS ==="

# Requêtes vers la zone privée
echo "Requêtes vers la zone privée lab.internal..."
for i in {1..5}; do
    dig vm2.lab.internal +short
    dig db.lab.internal +short
done
echo ""

# Requêtes vers des domaines externes
echo "Requêtes vers des domaines externes..."
dig www.google.com +short
dig www.github.com +short
echo ""

# Requêtes inexistantes (pour générer NXDOMAIN)
echo "Requêtes inexistantes (génération de NXDOMAIN)..."
dig nonexistent.lab.internal +short
echo ""

echo "Requêtes DNS générées!"
EOF

echo ""
echo "Trafic DNS généré avec succès !"
echo ""
echo "Attendez quelques minutes pour que les logs se propagent..."
