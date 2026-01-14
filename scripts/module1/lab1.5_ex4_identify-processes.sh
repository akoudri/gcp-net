#!/bin/bash
# Lab 1.5 - Exercice 1.5.4 : Identifier les processus avec lsof
# Objectif : Lier les ports aux processus

set -e

echo "=== Lab 1.5 - Exercice 4 : Identifier les processus ==="
echo ""

# Vérifier si lsof est installé
if ! command -v lsof &> /dev/null; then
    echo "⚠️  lsof n'est pas installé."
    echo ""
    echo "Pour l'installer :"
    echo "  Ubuntu/Debian : sudo apt install lsof"
    echo "  CentOS/RHEL   : sudo yum install lsof"
    echo ""
    exit 1
fi

# Lancer un serveur web
echo "Lancement d'un serveur web sur le port 8080..."
python3 -m http.server 8080 &
SERVER_PID=$!
sleep 2
echo "✓ Serveur démarré (PID: $SERVER_PID)"
echo ""

# Trouver quel processus utilise le port 8080
echo "=== Processus utilisant le port 8080 ==="
sudo lsof -i :8080
echo ""

# Port SSH (si disponible)
echo "=== Processus utilisant le port 22 (SSH) ==="
sudo lsof -i :22 2>/dev/null || echo "Aucun processus sur le port 22"
echo ""

# Lister toutes les connexions réseau d'un processus
echo "=== Connexions réseau du serveur Python (PID: $SERVER_PID) ==="
sudo lsof -i -a -p $SERVER_PID
echo ""

# Nettoyage
kill $SERVER_PID 2>/dev/null || true
echo ""

echo "💡 Colonnes importantes de lsof :"
echo "   - COMMAND : Nom du processus"
echo "   - PID     : Process ID"
echo "   - USER    : Utilisateur propriétaire"
echo "   - NAME    : Adresse:Port (local et distant)"
echo "   - TYPE    : IPv4, IPv6"
echo "   - NODE    : TCP, UDP"
echo ""
echo "Utilisation pratique :"
echo "   - Trouver qui utilise un port : sudo lsof -i :PORT"
echo "   - Voir les connexions d'un processus : sudo lsof -p PID"
