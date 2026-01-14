#!/bin/bash
# Lab 1.6 - Exercice 1.6.5 : Tester différents serveurs DNS
# Objectif : Comparer les performances de différents DNS

set -e

echo "=== Lab 1.6 - Exercice 5 : Tester différents serveurs DNS ==="
echo ""

DOMAIN="google.com"

# Utiliser le DNS de Google
echo "=== DNS de Google (8.8.8.8) ==="
dig @8.8.8.8 $DOMAIN +stats | grep -E "(Query time|SERVER)"
echo ""

# Utiliser le DNS de Cloudflare
echo "=== DNS de Cloudflare (1.1.1.1) ==="
dig @1.1.1.1 $DOMAIN +stats | grep -E "(Query time|SERVER)"
echo ""

# Utiliser le DNS de Quad9
echo "=== DNS de Quad9 (9.9.9.9) ==="
dig @9.9.9.9 $DOMAIN +stats | grep -E "(Query time|SERVER)"
echo ""

# DNS par défaut
echo "=== DNS par défaut (système) ==="
dig $DOMAIN +stats | grep -E "(Query time|SERVER)"
echo ""

# Comparaison détaillée
echo "=== Comparaison des temps de réponse ==="
echo "Domain: $DOMAIN"
echo ""

for DNS in "8.8.8.8 Google" "1.1.1.1 Cloudflare" "9.9.9.9 Quad9"; do
    IP=$(echo $DNS | awk '{print $1}')
    NAME=$(echo $DNS | awk '{print $2}')
    TIME=$(dig @$IP $DOMAIN | grep "Query time" | awk '{print $4}')
    printf "%-15s : %s ms\n" "$NAME ($IP)" "$TIME"
done
echo ""

echo "💡 Différences entre les DNS publics :"
echo ""
echo "Google DNS (8.8.8.8, 8.8.4.4) :"
echo "   - Rapide et fiable"
echo "   - Peut enregistrer vos requêtes"
echo ""
echo "Cloudflare DNS (1.1.1.1, 1.0.0.1) :"
echo "   - Focus sur la vie privée (ne log pas les IPs)"
echo "   - Très rapide"
echo ""
echo "Quad9 DNS (9.9.9.9) :"
echo "   - Bloque les domaines malveillants"
echo "   - Focus sur la sécurité"
echo ""
echo "Questions à considérer :"
echo "1. Quel DNS est le plus rapide pour vous ? Pourquoi ?"
echo "   → Dépend de votre localisation et du cache"
echo "2. Comment changer le DNS de votre système ?"
echo "   → /etc/resolv.conf ou NetworkManager"
