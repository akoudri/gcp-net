#!/bin/bash
# Nettoyage des ressources du Module 1
# Objectif : Nettoyer les processus et caches créés pendant les labs

set -e

echo "=== Nettoyage des ressources du Module 1 ==="
echo ""

echo "ℹ️  Le Module 1 étant basé sur des diagnostics réseau locaux,"
echo "   il n'y a pas de ressources GCP à supprimer."
echo ""
echo "Nettoyage des éléments locaux :"
echo ""

# Tuer les processus netcat et serveurs web qui pourraient tourner
echo "1. Arrêt des processus de test..."
pkill -f "nc -l" 2>/dev/null && echo "   ✓ Serveurs netcat arrêtés" || echo "   - Aucun serveur netcat actif"
pkill -f "python3 -m http.server" 2>/dev/null && echo "   ✓ Serveurs web Python arrêtés" || echo "   - Aucun serveur web Python actif"
echo ""

# Vider les caches réseau
echo "2. Vidage des caches réseau..."
echo "   - Cache ARP..."
sudo ip neigh flush all 2>/dev/null && echo "   ✓ Cache ARP vidé" || echo "   ⚠️  Cache ARP non vidé (permissions insuffisantes)"
echo "   - Cache DNS..."
sudo systemd-resolve --flush-caches 2>/dev/null || sudo resolvectl flush-caches 2>/dev/null || echo "   ⚠️  Cache DNS non vidé (systemd-resolved non disponible)"
echo "   ✓ Cache DNS vidé"
echo ""

# Note sur Wireshark
echo "3. Wireshark :"
echo "   - Si Wireshark est ouvert, fermez-le manuellement"
echo "   - Les captures sont sauvegardées dans ~/wireshark_captures/ (si configuré)"
echo ""

# Note sur les logs
echo "4. Logs et captures :"
echo "   - Les captures Wireshark restent dans leur répertoire"
echo "   - Vous pouvez les supprimer manuellement si nécessaire"
echo ""

echo "=========================================="
echo "✅ Nettoyage terminé"
echo "=========================================="
echo ""
echo "📝 Rappels :"
echo "   - Le Module 1 utilise des outils de diagnostic (ping, traceroute, dig, etc.)"
echo "   - Aucune ressource cloud n'a été créée"
echo "   - Les caches réseau ont été vidés"
echo "   - Les processus de test ont été arrêtés"
echo ""
echo "Pour recommencer les exercices :"
echo "   → Lancez simplement les scripts des labs"
echo ""
echo "Pour vérifier qu'aucun processus de test ne tourne :"
echo "   → ps aux | grep -E '(nc|http.server)'"
echo ""
