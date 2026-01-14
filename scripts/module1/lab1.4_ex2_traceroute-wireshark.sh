#!/bin/bash
# Lab 1.4 - Exercice 1.4.2 : Observer traceroute dans Wireshark
# Objectif : Comprendre le fonctionnement interne de traceroute

set -e

echo "=== Lab 1.4 - Exercice 2 : Traceroute avec Wireshark ==="
echo ""

echo "⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark"
echo "   - Appliquez le filtre : icmp || udp.port >= 33434"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Exécuter traceroute
echo "Exécution de traceroute vers 8.8.8.8..."
echo ""
traceroute -n 8.8.8.8
echo ""

echo "📊 ANALYSE DANS WIRESHARK :"
echo ""
echo "1. Observez les paquets UDP/ICMP avec TTL=1, puis TTL=2, etc."
echo "2. Observez les réponses ICMP 'Time-to-live exceeded'"
echo "3. Notez l'adresse source de chaque réponse = adresse du routeur"
echo ""
echo "💡 Fonctionnement de traceroute :"
echo "   - Envoie des paquets avec TTL croissants (1, 2, 3...)"
echo "   - Chaque routeur décrémente le TTL"
echo "   - Quand TTL=0, le routeur répond avec ICMP Type 11"
echo "   - Révèle ainsi chaque saut du chemin"
