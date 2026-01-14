#!/bin/bash
# Lab 1.5 - Exercice 1.5.1 : Le 3-way handshake TCP
# Objectif : Observer l'établissement d'une connexion TCP

set -e

echo "=== Lab 1.5 - Exercice 1 : Le 3-way handshake TCP ==="
echo ""

echo "⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark"
echo "   - Appliquez le filtre : tcp.port == 80"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Établir une connexion HTTP
echo "Établissement d'une connexion HTTP vers example.com..."
echo ""
curl -I http://example.com
echo ""

echo "📊 ANALYSE DU HANDSHAKE DANS WIRESHARK :"
echo ""
echo "1. SYN : Client → Serveur"
echo "   - Flags: SYN"
echo "   - Seq = X (numéro de séquence initial aléatoire)"
echo ""
echo "2. SYN-ACK : Serveur → Client"
echo "   - Flags: SYN, ACK"
echo "   - Seq = Y (ISN du serveur)"
echo "   - Ack = X + 1"
echo ""
echo "3. ACK : Client → Serveur"
echo "   - Flags: ACK"
echo "   - Seq = X + 1"
echo "   - Ack = Y + 1"
echo ""
echo "Questions à considérer :"
echo "1. Quels sont les numéros de séquence initiaux (ISN) ?"
echo "2. Combien de paquets pour établir la connexion ? (3)"
echo "3. Observez la fermeture (FIN, FIN-ACK ou RST)"
