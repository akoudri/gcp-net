#!/bin/bash
# Lab 2.4 - Exercice 2.4.6 : Tester la connectivité via l'appliance
# Objectif : Vérifier que le trafic passe par l'appliance

set -e

echo "=== Lab 2.4 - Exercice 6 : Test de connectivité via l'appliance ==="
echo ""

export ZONE="europe-west1-b"

echo "Instructions de test :"
echo ""
echo "=== Test 1 : Ping depuis client-a vers client-b ==="
echo ""
echo "1. Connectez-vous à client-a :"
echo "   gcloud compute ssh client-a --zone=$ZONE --tunnel-through-iap"
echo ""
echo "2. Pingez client-b (devrait passer par l'appliance) :"
echo "   ping -c 5 10.2.0.10"
echo ""
echo "3. Vérifiez le chemin avec traceroute :"
echo "   traceroute 10.2.0.10"
echo "   # Devrait montrer 10.1.0.5 (appliance) comme premier hop"
echo ""
echo ""
echo "=== Test 2 : Capture de trafic sur l'appliance ==="
echo ""
echo "1. Dans un autre terminal, connectez-vous à l'appliance :"
echo "   gcloud compute ssh appliance-vm --zone=$ZONE --tunnel-through-iap"
echo ""
echo "2. Lancez tcpdump pour capturer le trafic ICMP :"
echo "   sudo tcpdump -i any icmp -n"
echo ""
echo "3. Relancez le ping depuis client-a (terminal 1)"
echo "   → Vous devriez voir les paquets transiter par l'appliance"
echo ""
echo ""
echo "Questions à considérer :"
echo "1. Le traceroute montre-t-il l'appliance comme hop intermédiaire ?"
echo "2. Que se passe-t-il si vous désactivez ip_forward sur l'appliance ?"
echo "3. Cas d'usage en production : firewall, IDS/IPS, proxy, VPN gateway"
