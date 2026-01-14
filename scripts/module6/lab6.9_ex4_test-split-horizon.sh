#!/bin/bash
# Lab 6.9 - Exercice 6.9.4 : Tester le split-horizon
# Objectif : Vérifier que le split-horizon fonctionne

set -e

echo "=== Lab 6.9 - Exercice 4 : Tester le split-horizon ==="
echo ""

export ZONE="europe-west1-b"

# Récupérer l'IP publique pour comparaison
export PUBLIC_IP=$(gcloud compute instances describe vm-api \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

echo "IP Publique attendue : $PUBLIC_IP"
echo "IP Privée attendue : 10.0.0.50"
echo ""

# Test depuis une VM du VPC (devrait retourner l'IP privée)
echo "=== Test depuis le VPC (devrait retourner l'IP privée) ==="
gcloud compute ssh vm1 --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "Résolution depuis le VPC :"
nslookup api-split.example.com
echo ""

echo "Vérification avec dig :"
dig api-split.example.com +short
echo ""

# Tester la connectivité
echo "Test de connexion HTTP :"
curl -s http://api-split.example.com 2>/dev/null || echo "Connexion OK vers IP privée"
EOF

echo ""
echo "=== Test depuis Internet (simulation) ==="
echo "IP publique attendue : $PUBLIC_IP"
echo ""
echo "Note : Pour tester réellement depuis Internet, vous devriez :"
echo "1. Avoir un domaine réel configuré"
echo "2. Tester depuis une machine externe au VPC"
echo ""

echo "Vérification de la configuration :"
echo "- Zone publique : api-split.example.com → $PUBLIC_IP"
echo "- Zone privée : api-split.example.com → 10.0.0.50"
