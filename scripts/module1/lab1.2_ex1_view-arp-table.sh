#!/bin/bash
# Lab 1.2 - Exercice 1.2.1 : Consulter la table ARP
# Objectif : Observer la table ARP et son fonctionnement

set -e

echo "=== Lab 1.2 - Exercice 1 : Consulter la table ARP ==="
echo ""

# Linux - Méthode moderne
echo "=== Table ARP (ip neigh) ==="
ip neigh show
echo ""

# Méthode classique
echo "=== Table ARP (arp -a) ==="
arp -a 2>/dev/null || echo "arp non disponible (installer net-tools)"
echo ""

echo "Questions à considérer :"
echo "1. Quelles entrées sont présentes dans votre table ARP ?"
echo "2. Trouvez-vous l'adresse MAC de votre passerelle ?"
echo "3. Que signifient les états REACHABLE, STALE, DELAY ?"
echo ""
echo "Note: Lancez ce script plusieurs fois pour observer l'évolution des états."
