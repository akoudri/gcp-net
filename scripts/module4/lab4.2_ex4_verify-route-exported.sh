#!/bin/bash
# Lab 4.2 - Exercice 4.2.4 : Vérifier que la route est maintenant visible
# Objectif : Constater que la route personnalisée apparaît dans le VPC peer

set -e

echo "=== Lab 4.2 - Exercice 4 : Vérifier que la route est maintenant visible ==="
echo ""

# Variables
export VPC_BETA="vpc-beta"

echo "Vérification des routes dans VPC Beta après activation de l'import..."
echo ""

# Vérifier les routes dans VPC Beta (la route custom devrait apparaître)
echo "=== Routes dans VPC Beta ==="
gcloud compute routes list --filter="network=$VPC_BETA"
echo ""

echo "Observation :"
echo "La route 192.168.100.0/24 devrait maintenant être visible avec un tag 'peering'"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi l'export des routes personnalisées est-il désactivé par défaut ?"
echo "2. Dans quel scénario activeriez-vous l'export/import des routes ?"
echo "3. Quels risques peut présenter l'export de routes personnalisées ?"
