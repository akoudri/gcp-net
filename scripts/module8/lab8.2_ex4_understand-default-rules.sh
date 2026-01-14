#!/bin/bash
# Lab 8.2 - Exercice 8.2.4 : Comprendre les règles par défaut
# Objectif : Analyser les règles de pare-feu implicites

set -e

echo "=== Lab 8.2 - Exercice 4 : Comprendre les règles par défaut ==="
echo ""

export VPC_NAME="vpc-security-lab"

echo "VPC : $VPC_NAME"
echo ""

# Lister les règles de pare-feu par défaut du VPC
echo ">>> Règles de pare-feu actuelles du VPC..."
gcloud compute firewall-rules list \
    --filter="network:$VPC_NAME" \
    --format="table(name,direction,priority,sourceRanges,allowed)"

echo ""
echo "=== Règles implicites (non visibles dans la liste) ==="
echo ""
echo "┌────────────────────────┬──────────┬─────────────────────────────────┐"
echo "│ Règle                  │ Priorité │ Comportement                    │"
echo "├────────────────────────┼──────────┼─────────────────────────────────┤"
echo "│ Deny all ingress       │ 65535    │ Bloque tout trafic entrant      │"
echo "│ Allow all egress       │ 65535    │ Autorise tout trafic sortant    │"
echo "└────────────────────────┴──────────┴─────────────────────────────────┘"
echo ""
echo "IMPORTANT : Ces règles ne peuvent pas être supprimées mais peuvent être"
echo "            'overridées' par des règles avec une priorité plus haute (nombre plus bas)."
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi ces règles implicites ne sont-elles pas visibles dans la liste ?"
echo "2. Comment créer une règle qui prime sur la règle implicite deny all ingress ?"
echo "3. Quel est l'impact de la règle allow all egress sur la sécurité ?"
