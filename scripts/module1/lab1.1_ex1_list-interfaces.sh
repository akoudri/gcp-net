#!/bin/bash
# Lab 1.1 - Exercice 1.1.1 : Lister les interfaces réseau
# Objectif : Identifier les interfaces réseau de la machine

set -e

echo "=== Lab 1.1 - Exercice 1 : Lister les interfaces réseau ==="
echo ""

# Linux - Méthode moderne (iproute2)
echo "=== Méthode moderne (ip link) ==="
ip link show
echo ""

# Linux - Méthode classique
echo "=== Méthode classique (ifconfig) ==="
ifconfig -a 2>/dev/null || echo "ifconfig non disponible (installer net-tools)"
echo ""

echo "Questions à considérer :"
echo "1. Combien d'interfaces réseau avez-vous ? Lesquelles sont actives ?"
echo "2. Quelle est l'adresse MAC de votre interface principale ?"
echo "3. Qu'est-ce que l'interface 'lo' (loopback) ?"
