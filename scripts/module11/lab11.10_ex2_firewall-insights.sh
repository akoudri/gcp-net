#!/bin/bash
# Lab 11.10 - Exercice 11.10.2 : Firewall Insights
# Objectif : Analyser les insights de pare-feu

set -e

echo "=== Lab 11.10 - Exercice 2 : Firewall Insights ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

echo "Recherche d'insights sur les règles de pare-feu..."
echo ""

# Lister les insights de pare-feu
gcloud recommender insights list \
    --insight-type=google.compute.firewall.Insight \
    --location=global \
    --project=$PROJECT_ID \
    --format="table(name,insightSubtype,description)"

echo ""
echo "=================================="
echo ""

echo "Types d'insights détectés :"
echo "  - SHADOWED_RULE       : Règle masquée par une autre règle"
echo "  - OVERLY_PERMISSIVE   : Règle trop permissive"
echo "  - UNUSED_ATTRIBUTE    : Attribut non utilisé dans la règle"
echo "  - REDUNDANT_RULE      : Règle redondante"
echo ""

echo "Note: Si aucun insight n'apparaît, cela signifie que vos règles sont optimales."
echo ""
echo "Consultez Firewall Insights dans la Console GCP :"
echo "  Navigation: Network Intelligence Center → Firewall Insights"
