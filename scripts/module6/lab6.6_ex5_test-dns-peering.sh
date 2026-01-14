#!/bin/bash
# Lab 6.6 - Exercice 6.6.5 : Tester la résolution via peering DNS
# Objectif : Vérifier que le peering DNS fonctionne

set -e

echo "=== Lab 6.6 - Exercice 5 : Tester la résolution via peering DNS ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM Spoke pour tester le peering DNS..."
echo ""

# Se connecter à la VM spoke
gcloud compute ssh vm-spoke --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test peering DNS ==="

echo "Test de résolution pour api.services.internal :"
nslookup api.services.internal
echo ""

echo "Test de résolution pour cache.services.internal :"
dig cache.services.internal +short
echo ""

echo "Test de résolution pour monitoring.services.internal :"
dig monitoring.services.internal +short
echo ""
EOF

echo ""
echo "Tests de peering DNS terminés !"
echo ""
echo "Questions à considérer :"
echo "1. La VM spoke peut-elle faire un ping vers api.services.internal ?"
echo "2. Quelle est la différence entre peering DNS et peering VPC ?"
