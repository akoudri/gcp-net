#!/bin/bash
# Lab 3.4 - Exercice 3.4.4 : Comprendre le mode de routage
# Objectif : Comprendre la différence entre GLOBAL et REGIONAL

set -e

echo "=== Lab 3.4 - Exercice 4 : Comprendre le mode de routage ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

echo "VPC : $VPC_NAME"
echo ""

# Vérifier le mode de routage du VPC
echo "=== Mode de routage du VPC ==="
MODE=$(gcloud compute networks describe $VPC_NAME \
    --format="get(routingConfig.routingMode)")

echo "Mode actuel : $MODE"
echo ""

echo "Explications :"
echo "- Mode GLOBAL : Les routes BGP sont propagées à toutes les régions"
echo "- Mode REGIONAL : Les routes BGP sont limitées à la région du Cloud Router"
echo ""

echo "Questions à considérer :"
echo "1. Dans quel cas privilégier le mode REGIONAL ?"
echo "2. Quel est l'impact du mode de routage sur les coûts ?"
echo ""
