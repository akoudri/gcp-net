#!/bin/bash
# Lab 6.1 - Exercice 6.1.7 : Tester la résolution DNS
# Objectif : Vérifier que la résolution DNS fonctionne depuis les VMs

set -e

echo "=== Lab 6.1 - Exercice 7 : Tester la résolution DNS ==="
echo ""

# Variables
export ZONE="europe-west1-b"

echo "Connexion à VM1 pour tester la résolution DNS..."
echo ""

# Se connecter à vm1 et tester la résolution DNS
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test nslookup ==="
nslookup vm2.lab.internal
echo ""

echo "=== Test dig ==="
dig vm2.lab.internal +short
echo ""

echo "=== Test dig détaillé ==="
dig db.lab.internal
echo ""

echo "=== Test CNAME ==="
nslookup www.lab.internal
nslookup database.lab.internal
echo ""

echo "=== Test TXT ==="
dig metadata.lab.internal TXT +short
echo ""

echo "=== Test connectivité ==="
ping -c 3 vm2.lab.internal
ping -c 3 db.lab.internal
echo ""

echo "=== Serveur DNS utilisé ==="
cat /etc/resolv.conf
echo ""
EOF

echo ""
echo "Tests terminés !"
echo ""
echo "Questions à considérer :"
echo "1. Quel serveur DNS est configuré sur les VMs GCP ?"
echo "2. Pourquoi utiliser un CNAME plutôt qu'un second enregistrement A ?"
