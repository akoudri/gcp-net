#!/bin/bash
# Lab 1.3 - Exercice 1.3.3 : Comprendre le TTL et son décrémentation
# Objectif : Observer l'expiration du TTL

set -e

echo "=== Lab 1.3 - Exercice 3 : TTL et décrémentation ==="
echo ""

echo "⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark"
echo "   - Appliquez le filtre : icmp"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Envoyer des pings avec différents TTL
echo "1. Ping avec TTL=1 (expire au premier routeur)..."
ping -c 1 -t 1 8.8.8.8 2>&1 || true
echo ""

echo "2. Ping avec TTL=5..."
ping -c 1 -t 5 8.8.8.8 2>&1 || true
echo ""

echo "3. Ping avec TTL=64 (défaut Linux)..."
ping -c 1 -t 64 8.8.8.8
echo ""

echo "📊 ANALYSE DANS WIRESHARK :"
echo ""
echo "Questions à considérer :"
echo "1. Que se passe-t-il quand le TTL expire ?"
echo "2. Quel message ICMP est retourné (Type et Code) ?"
echo "   → Cherchez 'Time-to-live exceeded' (Type 11, Code 0)"
echo "3. Qui envoie ce message ?"
echo "   → Le routeur où le TTL a expiré"
echo ""
echo "💡 Note : C'est ce mécanisme qu'utilise traceroute !"
