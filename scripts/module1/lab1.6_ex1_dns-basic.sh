#!/bin/bash
# Lab 1.6 - Exercice 1.6.1 : Résolution DNS basique
# Objectif : Comprendre le fonctionnement du DNS

set -e

echo "=== Lab 1.6 - Exercice 1 : Résolution DNS basique ==="
echo ""

# Avec dig (recommandé)
echo "=== Résolution avec dig ==="
dig google.com
echo ""

# Avec nslookup
echo "=== Résolution avec nslookup ==="
nslookup google.com
echo ""

# Résolution inverse (IP → nom)
echo "=== Résolution inverse (8.8.8.8 → nom) ==="
dig -x 8.8.8.8
echo ""

echo "📊 ANALYSE DE LA SORTIE DIG :"
echo ""
echo "Sections importantes :"
echo "   - QUESTION SECTION : la requête envoyée"
echo "   - ANSWER SECTION   : la réponse (adresse IP)"
echo "   - Query time       : temps de résolution (ms)"
echo "   - SERVER           : serveur DNS utilisé"
echo ""
echo "💡 La résolution inverse permet de retrouver le nom à partir de l'IP"
