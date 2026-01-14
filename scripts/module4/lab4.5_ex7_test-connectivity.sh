#!/bin/bash
# Lab 4.5 - Exercice 4.5.7 : Tester la connectivité
# Objectif : Vérifier que les VMs peuvent communiquer via le réseau partagé

set -e

echo "=== Lab 4.5 - Exercice 7 : Tester la connectivité ==="
echo ""

# Variables
export SERVICE_PROJECT_1="${SERVICE_PROJECT_1:-service-frontend-YYYYMMDD}"

if [ "$SERVICE_PROJECT_1" = "service-frontend-YYYYMMDD" ]; then
    echo "❌ Veuillez définir la variable SERVICE_PROJECT_1"
    exit 1
fi

echo "Test de connectivité entre les VMs..."
echo ""

# Se connecter à vm-frontend et ping vm-backend
echo "Connexion à vm-frontend et test vers backend..."
gcloud compute ssh vm-frontend \
    --project=$SERVICE_PROJECT_1 \
    --zone=europe-west1-b \
    --tunnel-through-iap << 'EOF'
echo "=== Test de connectivité vers backend ==="
echo "IP cible : 10.100.1.2 (ou l'IP de vm-backend)"
ping -c 5 10.100.1.2 2>/dev/null || echo "Vérifiez l'IP de vm-backend"
EOF

echo ""
echo "Test de connectivité terminé !"
echo ""

echo "Questions à considérer :"
echo "1. Les VMs sont dans des projets différents mais peuvent-elles communiquer ?"
echo "2. Qui gère les règles de pare-feu ?"
echo "3. Les équipes des projets de service peuvent-elles modifier le réseau ?"
