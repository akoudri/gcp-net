#!/bin/bash
# Lab 6.10 - Exercice 6.10.4 : Simuler des requêtes et observer la distribution
# Objectif : Créer un script pour tester la distribution WRR

set -e

echo "=== Lab 6.10 - Exercice 4 : Simuler des requêtes WRR ==="
echo ""

# Créer le script de test
cat << 'SCRIPT' > /tmp/test_wrr.sh
#!/bin/bash
# Test WRR distribution

DOMAIN="wrr.example-lab.com"
COUNT=100

echo "Testing WRR distribution with $COUNT queries..."
echo ""

declare -A results

for i in $(seq 1 $COUNT); do
    ip=$(dig +short $DOMAIN @8.8.8.8 | head -1)
    if [ -n "$ip" ]; then
        ((results[$ip]++))
    fi
    # Petit délai pour éviter le cache
    sleep 0.1
done

echo "Results:"
for ip in "${!results[@]}"; do
    pct=$((100 * ${results[$ip]} / $COUNT))
    echo "  $ip: ${results[$ip]} requests ($pct%)"
done
SCRIPT

chmod +x /tmp/test_wrr.sh

echo "Script de test créé : /tmp/test_wrr.sh"
echo ""

cat << 'NOTE'
Note : Ce script fonctionne uniquement si le domaine est réellement configuré
avec les NS de Cloud DNS chez votre registrar.

Pour exécuter le test :
    /tmp/test_wrr.sh

Le test effectue 100 requêtes DNS et affiche la distribution observée.
Vous devriez observer une distribution proche de 80/20.
NOTE
