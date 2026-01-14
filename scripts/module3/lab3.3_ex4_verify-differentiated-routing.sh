#!/bin/bash
# Lab 3.3 - Exercice 3.3.4 : Vérifier le routage différencié
# Objectif : Vérifier que le trafic est routé différemment selon les tags

set -e

echo "=== Lab 3.3 - Exercice 4 : Vérifier le routage différencié ==="
echo ""

export REGION_EU="europe-west1"

echo "Pour vérifier le routage différencié, vous devez ouvrir 3 terminaux :"
echo ""
echo "TERMINAL 1 - Capturer sur le proxy :"
echo "  gcloud compute ssh proxy-vm --zone=${REGION_EU}-b --tunnel-through-iap"
echo "  sudo tcpdump -i ens4 icmp -n"
echo ""
echo "TERMINAL 2 - Tester depuis client1 (avec tag) :"
echo "  gcloud compute ssh client1 --zone=${REGION_EU}-b --tunnel-through-iap"
echo "  ping -c 5 10.2.0.50"
echo "  traceroute -n 10.2.0.50"
echo ""
echo "TERMINAL 3 - Tester depuis client2 (sans tag) :"
echo "  gcloud compute ssh client2 --zone=${REGION_EU}-b --tunnel-through-iap"
echo "  ping -c 5 10.2.0.50"
echo "  traceroute -n 10.2.0.50"
echo ""
echo "Questions à vérifier :"
echo "1. Le tcpdump sur proxy-vm voit-il le trafic de client1 ?"
echo "2. Le tcpdump sur proxy-vm voit-il le trafic de client2 ?"
echo "3. Comparez les traceroutes des deux clients."
echo ""
echo "Note : Ce script affiche les instructions. Les tests doivent être effectués manuellement."
echo ""
