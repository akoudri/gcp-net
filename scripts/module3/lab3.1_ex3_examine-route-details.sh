#!/bin/bash
# Lab 3.1 - Exercice 3.1.3 : Examiner une route en détail
# Objectif : Comprendre le rôle de chaque type de route

set -e

echo "=== Lab 3.1 - Exercice 3 : Examiner une route en détail ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"

# Obtenir le nom exact de la route par défaut
echo "Recherche de la route par défaut..."
DEFAULT_ROUTE=$(gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=0.0.0.0/0" \
    --format="get(name)")

echo "Route par défaut : $DEFAULT_ROUTE"
echo ""

# Examiner les détails complets
echo "=== Détails de la route par défaut ==="
gcloud compute routes describe $DEFAULT_ROUTE
echo ""

# Examiner une route de sous-réseau
echo "Recherche d'une route de sous-réseau..."
SUBNET_ROUTE=$(gcloud compute routes list \
    --filter="network=$VPC_NAME AND destRange=10.1.0.0/24" \
    --format="get(name)")

echo "Route de sous-réseau : $SUBNET_ROUTE"
echo ""

echo "=== Détails de la route de sous-réseau ==="
gcloud compute routes describe $SUBNET_ROUTE
echo ""

echo "Questions à considérer :"
echo "1. Quelle est la priorité de la route par défaut ?"
echo "2. Les routes de sous-réseau ont-elles un next-hop explicite ?"
echo "3. Que signifie nextHopNetwork pour une route de sous-réseau ?"
echo ""
