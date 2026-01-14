#!/bin/bash
# Lab 2.4 - Exercice 2.4.4 : Configurer le routage sur l'appliance
# Objectif : Instructions pour configurer iptables sur l'appliance

set -e

echo "=== Lab 2.4 - Exercice 4 : Configurer le routage sur l'appliance ==="
echo ""

export ZONE="europe-west1-b"

echo "Instructions pour configurer l'appliance :"
echo ""
echo "1. Connectez-vous à l'appliance via IAP :"
echo "   gcloud compute ssh appliance-vm --zone=$ZONE --tunnel-through-iap"
echo ""
echo "2. Vérifiez les interfaces réseau :"
echo "   ip addr show"
echo ""
echo "3. Vérifiez que le forwarding IP est activé :"
echo "   cat /proc/sys/net/ipv4/ip_forward  # Doit afficher 1"
echo ""
echo "4. Vérifiez la table de routage :"
echo "   ip route show"
echo ""
echo "5. Configurez iptables pour permettre le forwarding :"
echo "   sudo iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE"
echo "   sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE"
echo "   sudo iptables -A FORWARD -i ens4 -o ens5 -j ACCEPT"
echo "   sudo iptables -A FORWARD -i ens5 -o ens4 -j ACCEPT"
echo ""
echo "6. Vérifiez les règles iptables :"
echo "   sudo iptables -L -v -n"
echo "   sudo iptables -t nat -L -v -n"
echo ""
echo "Note : ens4 = première interface (VPC-A), ens5 = deuxième interface (VPC-B)"
