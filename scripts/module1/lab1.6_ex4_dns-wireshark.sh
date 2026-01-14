#!/bin/bash
# Lab 1.6 - Exercice 1.6.4 : Observer DNS dans Wireshark
# Objectif : Analyser les requêtes DNS au niveau paquet

set -e

echo "=== Lab 1.6 - Exercice 4 : DNS dans Wireshark ==="
echo ""

# Vider le cache DNS
echo "1. Vidage du cache DNS..."
sudo systemd-resolve --flush-caches 2>/dev/null || sudo resolvectl flush-caches 2>/dev/null || echo "⚠️  Cache DNS non vidé (systemd-resolved non disponible)"
echo "✓ Cache DNS vidé"
echo ""

echo "2. ⚠️  INSTRUCTIONS :"
echo "   - Ouvrez Wireshark"
echo "   - Appliquez le filtre : dns"
echo "   - Cliquez sur 'Start capturing'"
echo ""
read -p "Appuyez sur Entrée quand Wireshark est prêt..."
echo ""

# Effectuer des résolutions
echo "3. Résolution de example.com..."
dig example.com +short
echo ""

echo "4. Résolution de amazon.fr..."
dig amazon.fr +short
echo ""

echo "📊 ANALYSE DANS WIRESHARK :"
echo ""
echo "Structure d'une requête DNS :"
echo "   - Port utilisé      : UDP 53 (généralement)"
echo "   - Transaction ID    : pour corréler requête/réponse"
echo "   - Flags             : QR (query/response), RD (recursion desired)"
echo "   - Questions         : nom demandé, type (A, AAAA, MX...)"
echo ""
echo "Structure d'une réponse DNS :"
echo "   - Reprend le Transaction ID de la requête"
echo "   - Answer section    : la/les réponse(s)"
echo "   - Authority section : serveurs autoritaires"
echo "   - Additional section: informations supplémentaires"
echo ""
echo "💡 DNS utilise UDP pour la rapidité, mais peut utiliser TCP"
echo "   pour les grandes réponses (> 512 octets) ou les transferts de zone."
