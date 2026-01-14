#!/bin/bash
# Lab 1.3 - Exercice 1.3.2 : Observer la fragmentation IP
# Objectif : Comprendre la fragmentation des paquets IP

set -e

echo "=== Lab 1.3 - Exercice 2 : Observer la fragmentation IP ==="
echo ""

echo "⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark"
echo "   - Appliquez le filtre : ip.flags.mf == 1 || ip.frag_offset > 0"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Envoyer un paquet plus grand que la MTU standard
echo "Envoi d'un paquet de 3000 octets vers 8.8.8.8..."
echo "Note: -s spécifie la taille des données (hors en-têtes)"
echo ""
ping -c 1 -s 3000 8.8.8.8
echo ""

echo "📊 ANALYSE DANS WIRESHARK :"
echo ""
echo "Questions à considérer :"
echo "1. En combien de fragments le paquet a-t-il été divisé ?"
echo "2. Quel est le Fragment Offset de chaque fragment ?"
echo "3. Comment le destinataire sait-il que c'est le dernier fragment ?"
echo ""
echo "💡 Indices :"
echo "   - MTU standard Ethernet : 1500 octets"
echo "   - Cherchez le flag 'More Fragments' (MF)"
echo "   - Le dernier fragment a MF=0"
