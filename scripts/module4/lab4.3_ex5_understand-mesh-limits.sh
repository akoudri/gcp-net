#!/bin/bash
# Lab 4.3 - Exercice 4.3.5 : Comprendre les limites du full mesh
# Objectif : Calculer et comprendre les limites du peering full mesh

set -e

echo "=== Lab 4.3 - Exercice 5 : Comprendre les limites du full mesh ==="
echo ""

echo "=== Limites du Full Mesh ==="
echo ""
echo "Formule : n VPC nécessitent n × (n-1) peerings au total"
echo "Limite GCP : 25 peerings par VPC maximum"
echo ""

cat << 'EOF'
┌───────────────┬──────────────────┬────────────────┐
│ Nombre de VPC │ Peerings par VPC │ Total peerings │
├───────────────┼──────────────────┼────────────────┤
│ 3             │ 2                │ 6              │
│ 5             │ 4                │ 20             │
│ 10            │ 9                │ 90             │
│ 25            │ 24               │ 600            │
│ 26            │ 25               │ 650 ⚠️ LIMITE  │
└───────────────┴──────────────────┴────────────────┘
EOF

echo ""
echo "Conclusion :"
echo "Avec la limite de 25 peerings par VPC, le full mesh ne fonctionne que jusqu'à 26 VPC."
echo "Pour plus de VPC, il faut une architecture hub-and-spoke avec transit."
echo ""

# Calculer pour le projet actuel
echo "=== État actuel du projet ==="
TOTAL_VPCS=$(gcloud compute networks list --format="value(name)" | grep -E "^vpc-" | wc -l)
echo "Nombre de VPC (préfixe vpc-) : $TOTAL_VPCS"

if [ $TOTAL_VPCS -gt 0 ]; then
    PEERINGS_NEEDED=$((TOTAL_VPCS * (TOTAL_VPCS - 1)))
    echo "Peerings nécessaires pour full mesh : $PEERINGS_NEEDED"

    if [ $TOTAL_VPCS -le 26 ]; then
        echo "✓ Full mesh possible"
    else
        echo "✗ Full mesh impossible - Architecture hub-and-spoke recommandée"
    fi
fi

echo ""
