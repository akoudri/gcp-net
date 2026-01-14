#!/bin/bash
# Lab 1.4 - Exercice 1.4.4 (Bonus) : MTR - traceroute continu
# Objectif : Observer les statistiques en temps réel

set -e

echo "=== Lab 1.4 - Exercice 4 (Bonus) : MTR ==="
echo ""

# Vérifier si mtr est installé
if ! command -v mtr &> /dev/null; then
    echo "⚠️  MTR n'est pas installé."
    echo ""
    echo "Pour l'installer :"
    echo "  Ubuntu/Debian : sudo apt install mtr"
    echo "  CentOS/RHEL   : sudo yum install mtr"
    echo "  Fedora        : sudo dnf install mtr"
    echo ""
    exit 1
fi

echo "Lancement de MTR vers google.com..."
echo ""
echo "💡 MTR combine ping et traceroute :"
echo "   - Affiche chaque saut du chemin"
echo "   - Mesure en continu : perte de paquets, latence min/avg/max"
echo "   - Utile pour diagnostiquer problèmes réseau intermittents"
echo ""
echo "Touches utiles :"
echo "   - q : quitter"
echo "   - d : toggle display mode"
echo "   - n : toggle DNS resolution"
echo ""
read -p "Appuyez sur Entrée pour lancer MTR..."
echo ""

# Lancer mtr (mode interactif)
sudo mtr google.com
