#!/bin/bash
# Lab 1.4 - Exercice 1.4.3 : Comparer les chemins réseau
# Objectif : Analyser les différences de routage

set -e

echo "=== Lab 1.4 - Exercice 3 : Comparer les chemins ==="
echo ""

# Tracer vers plusieurs destinations
echo "=== Traceroute vers google.fr ==="
traceroute -n -m 15 google.fr
echo ""
echo "Press Enter to continue..."
read

echo "=== Traceroute vers cloudflare.com ==="
traceroute -n -m 15 cloudflare.com
echo ""
echo "Press Enter to continue..."
read

echo "=== Traceroute vers amazon.com ==="
traceroute -n -m 15 amazon.com
echo ""

echo "Questions à considérer :"
echo "1. Les premiers sauts sont-ils les mêmes ? Pourquoi ?"
echo "   → Oui, ils passent par votre FAI local"
echo "2. À partir de quel saut les chemins divergent-ils ?"
echo "   → Généralement après le réseau de votre FAI"
echo ""
echo "💡 Les chemins divergent quand ils atteignent différents"
echo "   réseaux backbone ou points d'échange (IXP)"
