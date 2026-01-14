#!/bin/bash
# Lab 1.5 - Exercice 1.5.3 : Observer les connexions avec ss/netstat
# Objectif : Analyser les ports et connexions TCP/UDP

set -e

echo "=== Lab 1.5 - Exercice 3 : Observer les connexions ==="
echo ""

# Lancer un serveur web simple
echo "Lancement d'un serveur web sur le port 8080..."
python3 -m http.server 8080 &
SERVER_PID=$!
sleep 2
echo "✓ Serveur démarré (PID: $SERVER_PID)"
echo ""

# Observer les connexions
echo "=== Ports en écoute (LISTEN) ==="
ss -tuln | grep LISTEN
echo ""

echo "=== Connexions TCP établies ==="
ss -tun state established 2>/dev/null || ss -tun | grep ESTAB
echo ""

echo "=== Toutes les connexions TCP ==="
ss -tun
echo ""

# Faire une connexion au serveur
echo "Connexion au serveur local pour créer une connexion établie..."
curl -s http://localhost:8080/ > /dev/null &
CURL_PID=$!
sleep 1
echo ""

echo "=== Connexions après curl ==="
ss -tun state established 2>/dev/null | grep 8080 || ss -tun | grep 8080
echo ""

# Nettoyage
kill $SERVER_PID 2>/dev/null || true
kill $CURL_PID 2>/dev/null || true
echo ""

echo "Questions à considérer :"
echo "1. Quels ports sont en écoute sur votre machine ?"
echo "2. Dans quel état se trouve une connexion TCP en attente ?"
echo "   → LISTEN (serveur attend des connexions)"
echo "3. Que signifient les états :"
echo "   - LISTEN      : Serveur en attente de connexions"
echo "   - ESTABLISHED : Connexion active établie"
echo "   - TIME_WAIT   : Connexion fermée, attente avant réutilisation du port"
echo "   - CLOSE_WAIT  : En attente de fermeture par l'application"
