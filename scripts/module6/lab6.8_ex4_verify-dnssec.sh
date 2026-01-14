#!/bin/bash
# Lab 6.8 - Exercice 6.8.4 : Vérifier DNSSEC (si domaine réel)
# Objectif : Tester la validation DNSSEC

set -e

echo "=== Lab 6.8 - Exercice 4 : Vérifier DNSSEC ==="
echo ""

export DOMAIN="example-lab.com"

echo "Domaine : $DOMAIN"
echo ""
echo "Note : Ces commandes fonctionnent uniquement si :"
echo "1. Vous avez un domaine réel"
echo "2. Les NS records sont configurés chez votre registrar"
echo "3. Le DS record est publié dans la zone parente"
echo ""

cat << 'VERIFICATION'
=== Commandes de vérification DNSSEC ===

# Vérifier avec dig
dig +dnssec example-lab.com A

# Vérifier la chaîne de confiance
dig +trace +dnssec example-lab.com

# Outils en ligne pour vérifier DNSSEC:
- https://dnsviz.net/
- https://dnssec-analyzer.verisignlabs.com/

=== Exemple de test local ===
VERIFICATION

echo ""
echo "Test de résolution avec validation DNSSEC (si installé)..."
command -v delv &>/dev/null && delv "$DOMAIN" A || echo "delv non installé (paquet bind-utils)"
echo ""

echo "Pour un test complet, utilisez les outils en ligne mentionnés ci-dessus."
