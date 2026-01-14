#!/bin/bash
# Lab 5.7 - Exercice 5.7.5 : Tester la connectivité via PSC
# Objectif : Vérifier que le service est accessible via PSC

set -e

echo "=== Lab 5.7 - Exercice 5 : Tester la connectivité via PSC ==="
echo ""

export ZONE="europe-west1-b"

echo "Connexion à la VM consommateur pour tester le service..."
echo ""

# Se connecter à la VM consommateur
gcloud compute ssh consumer-vm --zone=$ZONE --tunnel-through-iap --command="
echo '=== Test 1 : Accès au service via l endpoint PSC ==='
curl http://10.60.0.100
echo ''
echo ''

echo '=== Test 2 : Requêtes multiples ==='
for i in {1..5}; do
    echo \"=== Requête \$i ===\"
    curl -s http://10.60.0.100
    echo ''
done
"

echo ""
echo "=== Connectivité PSC testée avec succès ! ==="
echo ""
echo "Questions à considérer :"
echo ""
echo "1. Le consommateur connaît-il l'IP réelle du backend (10.50.0.10) ?"
echo "   → Non, il voit uniquement l'endpoint PSC (10.60.0.100)"
echo "     dans son propre VPC."
echo ""
echo "2. Le trafic traverse-t-il Internet entre les deux VPC ?"
echo "   → Non, le trafic passe par le réseau privé de Google"
echo "     via Private Service Connect."
echo ""
echo "Avantages de PSC :"
echo "- Isolation complète des réseaux (pas de VPC Peering)"
echo "- Le consommateur et le producteur peuvent avoir des IPs qui se chevauchent"
echo "- Contrôle granulaire des accès"
echo "- Scalabilité (plusieurs consommateurs possible)"
