#!/bin/bash
# Lab 1.3 - Exercice 1.3.1 : Capturer et analyser une trame ICMP (ping)
# Objectif : Décortiquer une trame Ethernet complète

set -e

echo "=== Lab 1.3 - Exercice 1 : Capturer et analyser ICMP ==="
echo ""

echo "⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark et sélectionnez votre interface réseau"
echo "   - Appliquez le filtre : icmp"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Effectuer un ping
echo "Envoi de 3 pings vers 8.8.8.8..."
ping -c 3 8.8.8.8
echo ""

echo "📊 ANALYSE DANS WIRESHARK :"
echo ""
echo "Pour chaque paquet ICMP Echo Request, identifiez :"
echo ""
echo "📦 Couche 2 - Trame Ethernet :"
echo "   - Adresse MAC destination"
echo "   - Adresse MAC source"
echo "   - EtherType (devrait être 0x0800 pour IPv4)"
echo ""
echo "📦 Couche 3 - Paquet IP :"
echo "   - Version (4 ou 6)"
echo "   - IHL (Internet Header Length)"
echo "   - Total Length"
echo "   - TTL (Time To Live)"
echo "   - Protocol (1 = ICMP)"
echo "   - Adresse IP source"
echo "   - Adresse IP destination"
echo "   - Checksum"
echo ""
echo "📦 Couche ICMP :"
echo "   - Type (8 = Echo Request, 0 = Echo Reply)"
echo "   - Code"
echo "   - Checksum"
echo "   - Identifier et Sequence Number"
