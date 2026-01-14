#!/bin/bash
# Lab 1.2 - Exercice 1.2.3 : ARP pour une IP hors du sous-réseau local
# Objectif : Observer le comportement d'ARP pour une IP externe

set -e

echo "=== Lab 1.2 - Exercice 3 : ARP pour une IP externe ==="
echo ""

# Vider le cache ARP
echo "1. Vidage de la table ARP..."
sudo ip neigh flush all
echo "✓ Table ARP vidée"
echo ""

echo "2. ⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark et sélectionnez votre interface réseau"
echo "   - Appliquez le filtre : arp"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Ping vers une IP externe
echo "3. Envoi d'un ping vers 8.8.8.8 (DNS Google)..."
ping -c 1 8.8.8.8
echo ""

echo "4. 📊 ANALYSE :"
echo "   - Observer les requêtes ARP dans Wireshark"
echo "   - Vérifier la table ARP"
echo ""

ip neigh show
echo ""

echo "Questions à considérer :"
echo "1. Vers quelle IP la requête ARP est-elle envoyée ? Pourquoi ?"
echo "2. Expliquez pourquoi on ne fait pas ARP directement vers 8.8.8.8."
echo ""
echo "💡 Indice : Les paquets vers des IPs externes passent par la passerelle."
