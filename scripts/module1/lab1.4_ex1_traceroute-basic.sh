#!/bin/bash
# Lab 1.4 - Exercice 1.4.1 : Traceroute basique
# Objectif : Identifier les routeurs intermédiaires

set -e

echo "=== Lab 1.4 - Exercice 1 : Traceroute basique ==="
echo ""

# Traceroute vers google.com
echo "=== Traceroute vers google.com (UDP par défaut) ==="
traceroute google.com
echo ""

echo "=== Traceroute vers google.com (ICMP comme Windows) ==="
traceroute -I google.com
echo ""

echo "Questions à considérer :"
echo "1. Combien de sauts (hops) jusqu'à la destination ?"
echo "2. Quels routeurs identifiez-vous (FAI, backbone...) ?"
echo "3. Que signifient les '* * *' ?"
echo "   → Le routeur ne répond pas aux requêtes (firewall, config)"
echo ""
echo "💡 Chaque ligne = un routeur, 3 mesures de latence (ms)"
