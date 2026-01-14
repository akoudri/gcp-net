#!/bin/bash
# Lab 7.1 - Exercice 7.1.10 : Tester la connectivité
# Objectif : Tester la connectivité entre les VMs via le VPN

set -e

echo "=== Lab 7.1 - Exercice 10 : Tester la connectivité ==="
echo ""

export ZONE="europe-west1-b"

# Test depuis vm-gcp vers vm-onprem
echo ">>> Test depuis vm-gcp vers vm-onprem (192.168.0.10)..."
gcloud compute ssh vm-gcp --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test connectivité APRÈS VPN ==="
echo ""
echo "=== Ping ==="
ping -c 5 192.168.0.10

echo ""
echo "=== Traceroute ==="
traceroute -n 192.168.0.10

echo ""
echo "=== MTR (si disponible) ==="
mtr -r -c 10 192.168.0.10 2>/dev/null || echo "MTR non disponible"

echo ""
echo "=== Test accès Internet via Cloud NAT ==="
curl -s ifconfig.me
EOF

echo ""
echo ""

# Test inverse depuis vm-onprem vers vm-gcp
echo ">>> Test depuis vm-onprem vers vm-gcp (10.0.0.10)..."
gcloud compute ssh vm-onprem --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test depuis On-premise vers GCP ==="
ping -c 5 10.0.0.10
traceroute -n 10.0.0.10

echo ""
echo "=== Test accès Internet via Cloud NAT ==="
curl -s ifconfig.me
EOF

echo ""
echo "=== Tests de connectivité terminés ==="
echo ""
echo "Questions :"
echo "1. Combien de 'hops' montre le traceroute ? Pourquoi ?"
echo "2. Pourquoi avons-nous créé 4 tunnels au total ?"
echo "3. Comment vérifier que Cloud NAT fonctionne correctement ?"
