#!/bin/bash
# Lab 4.2 - Exercice 4.2.2 : Vérifier si la route est exportée par défaut
# Objectif : Constater que les routes personnalisées ne sont pas exportées par défaut

set -e

echo "=== Lab 4.2 - Exercice 2 : Vérifier si la route est exportée par défaut ==="
echo ""

# Variables
export VPC_BETA="vpc-beta"

echo "Vérification des routes dans VPC Beta..."
echo ""

# Vérifier les routes dans VPC Beta
echo "=== Routes dans VPC Beta ==="
gcloud compute routes list --filter="network=$VPC_BETA"
echo ""

echo "Observation :"
echo "La route custom-route-alpha (192.168.100.0/24) n'apparaît PAS dans VPC Beta"
echo "Car l'export des routes personnalisées est désactivé par défaut"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi cette restriction existe-t-elle ?"
echo "2. Comment activer l'export des routes personnalisées ?"
