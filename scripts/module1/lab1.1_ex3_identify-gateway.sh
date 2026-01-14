#!/bin/bash
# Lab 1.1 - Exercice 1.1.3 : Identifier la passerelle par défaut
# Objectif : Visualiser la table de routage

set -e

echo "=== Lab 1.1 - Exercice 3 : Identifier la passerelle par défaut ==="
echo ""

# Linux - Méthode moderne
echo "=== Table de routage (ip route) ==="
ip route show
echo ""

# Méthode classique
echo "=== Table de routage (route -n) ==="
route -n 2>/dev/null || echo "route non disponible (installer net-tools)"
echo ""

# Extraire la passerelle par défaut
echo "=== Passerelle par défaut ==="
ip route show default
echo ""

echo "Questions à considérer :"
echo "1. Quelle est l'adresse de votre passerelle par défaut ?"
echo "2. Que signifie la route 'default via X.X.X.X' ?"
echo "3. Identifiez les routes vers vos sous-réseaux locaux."
