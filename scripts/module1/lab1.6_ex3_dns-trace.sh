#!/bin/bash
# Lab 1.6 - Exercice 1.6.3 : Tracer la résolution DNS complète
# Objectif : Comprendre la hiérarchie DNS

set -e

echo "=== Lab 1.6 - Exercice 3 : Tracer la résolution DNS ==="
echo ""

echo "Résolution itérative depuis les serveurs racine..."
echo "Cela peut prendre quelques secondes..."
echo ""

# Résolution itérative depuis les serveurs racine
dig +trace google.com

echo ""
echo "📊 ANALYSE DE LA TRACE :"
echo ""
echo "La résolution se fait en 4 étapes :"
echo ""
echo "1. Serveurs racine (.)"
echo "   → Retournent les serveurs pour .com"
echo ""
echo "2. Serveurs TLD (.com)"
echo "   → Retournent les serveurs autoritaires pour google.com"
echo ""
echo "3. Serveurs autoritaires (google.com)"
echo "   → Retournent l'adresse IP finale"
echo ""
echo "4. Réponse finale"
echo "   → L'adresse IP de google.com"
echo ""
echo "💡 En pratique, votre résolveur DNS met en cache ces résultats"
echo "   pour accélérer les résolutions suivantes."
