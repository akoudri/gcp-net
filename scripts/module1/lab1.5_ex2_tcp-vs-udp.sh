#!/bin/bash
# Lab 1.5 - Exercice 1.5.2 : Comparaison TCP vs UDP avec netcat
# Objectif : Observer les différences entre TCP et UDP

set -e

echo "=== Lab 1.5 - Exercice 2 : TCP vs UDP avec netcat ==="
echo ""

# Vérifier si netcat est installé
if ! command -v nc &> /dev/null; then
    echo "⚠️  Netcat n'est pas installé."
    echo ""
    echo "Pour l'installer :"
    echo "  Ubuntu/Debian : sudo apt install netcat"
    echo "  CentOS/RHEL   : sudo yum install nc"
    echo ""
    exit 1
fi

echo "⚠️  INSTRUCTIONS :"
echo ""
echo "1. Ouvrez Wireshark avec les filtres :"
echo "   - tcp.port == 12345 (pour TCP)"
echo "   - udp.port == 12346 (pour UDP)"
echo ""
echo "2. Ouvrez DEUX autres terminaux :"
echo ""
echo "   TERMINAL 1 - Serveur TCP :"
echo "   $ nc -l -p 12345"
echo ""
echo "   TERMINAL 2 - Client TCP :"
echo "   $ nc localhost 12345"
echo "   (Tapez du texte et observez dans Wireshark)"
echo ""
echo "3. Puis testez UDP :"
echo ""
echo "   TERMINAL 1 - Serveur UDP :"
echo "   $ nc -u -l -p 12346"
echo ""
echo "   TERMINAL 2 - Client UDP :"
echo "   $ nc -u localhost 12346"
echo "   (Tapez du texte et observez dans Wireshark)"
echo ""
echo "📊 COMPARAISON DANS WIRESHARK :"
echo ""
echo "Questions à considérer :"
echo "1. Y a-t-il un handshake pour UDP ? (Non)"
echo "2. Observez les numéros de séquence TCP - comment évoluent-ils ?"
echo "3. Quelle est la taille des en-têtes TCP vs UDP ?"
echo "   - TCP : 20 octets minimum (plus options)"
echo "   - UDP : 8 octets seulement"
echo ""
read -p "Appuyez sur Entrée quand vous avez terminé l'analyse..."
