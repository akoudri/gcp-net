#!/bin/bash
# Lab 4.3 - Exercice 4.3.4 : Solution 1 - Peering direct Alpha ↔ Gamma
# Objectif : Résoudre le problème avec un peering direct

set -e

echo "=== Lab 4.3 - Exercice 4 : Solution 1 - Peering direct Alpha ↔ Gamma ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export VPC_ALPHA="vpc-alpha"
export VPC_GAMMA="vpc-gamma"
export ZONE="europe-west1-b"

echo "Création d'un peering direct entre Alpha et Gamma..."
echo ""

# Créer un peering direct entre Alpha et Gamma
echo "Création du peering de Alpha vers Gamma..."
gcloud compute networks peerings create peering-alpha-to-gamma \
    --network=$VPC_ALPHA \
    --peer-network=$VPC_GAMMA \
    --peer-project=$PROJECT_ID

echo ""

echo "Création du peering de Gamma vers Alpha..."
gcloud compute networks peerings create peering-gamma-to-alpha \
    --network=$VPC_GAMMA \
    --peer-network=$VPC_ALPHA \
    --peer-project=$PROJECT_ID

echo ""
echo "Peering direct Alpha ↔ Gamma créé !"
echo ""

# Attendre l'activation
echo "Attente de l'activation du peering..."
sleep 10

# Tester la connectivité Alpha → Gamma (fonctionne maintenant)
echo "Test: Alpha → Gamma (devrait maintenant fonctionner)..."
gcloud compute ssh vm-alpha --zone=$ZONE --tunnel-through-iap << 'EOF'
echo "=== Test Alpha → Gamma (direct) ==="
ping -c 3 10.30.1.10 && echo "SUCCESS" || echo "FAILED"
EOF

echo ""

# Compter les peerings de chaque VPC
echo "=== Nombre de peerings par VPC ==="
echo -n "Peerings de VPC Alpha: "
gcloud compute networks peerings list --network=$VPC_ALPHA --format="value(name)" | wc -l

echo -n "Peerings de VPC Beta: "
gcloud compute networks peerings list --network=$VPC_BETA --format="value(name)" | wc -l

echo -n "Peerings de VPC Gamma: "
gcloud compute networks peerings list --network=$VPC_GAMMA --format="value(name)" | wc -l

echo ""
echo "Question : Avec 4 VPC en full mesh, combien de peerings faut-il créer ?"
echo "Réponse : n × (n-1) peerings, soit 4 × 3 = 12 peerings"
