#!/bin/bash
# Lab 11.10 - Exercice 11.10.1 : Connectivity Tests
# Objectif : Créer et exécuter des tests de connectivité

set -e

echo "=== Lab 11.10 - Exercice 1 : Connectivity Tests ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export ZONE="europe-west1-b"

echo "Projet : $PROJECT_ID"
echo "Zone : $ZONE"
echo ""

# Créer un test de connectivité entre deux VMs
echo "1. Création du test de connectivité vm-source → vm-dest (port 80)..."
gcloud network-management connectivity-tests create test-source-to-dest \
    --source-instance=projects/${PROJECT_ID}/zones/${ZONE}/instances/vm-source \
    --destination-instance=projects/${PROJECT_ID}/zones/${ZONE}/instances/vm-dest \
    --destination-port=80 \
    --protocol=TCP

echo ""
echo "Test créé ! Exécution en cours..."
echo ""

# Exécuter le test
gcloud network-management connectivity-tests rerun test-source-to-dest

echo ""
echo "Test exécuté !"
echo ""

# Voir les résultats
echo "=== Résultats du test ==="
gcloud network-management connectivity-tests describe test-source-to-dest \
    --format="yaml(reachabilityDetails)"

echo ""
echo "=================================="
echo ""

# Créer un test vers Internet
echo "2. Création du test de connectivité vers Internet (8.8.8.8:443)..."
gcloud network-management connectivity-tests create test-to-internet \
    --source-instance=projects/${PROJECT_ID}/zones/${ZONE}/instances/vm-source \
    --destination-ip-address=8.8.8.8 \
    --destination-port=443 \
    --protocol=TCP

echo ""
echo "Test créé ! Exécution en cours..."
gcloud network-management connectivity-tests rerun test-to-internet

echo ""
echo "=== Résultats du test vers Internet ==="
gcloud network-management connectivity-tests describe test-to-internet \
    --format="yaml(reachabilityDetails)"

echo ""
echo "=================================="
echo ""

# Lister tous les tests
echo "=== Tous les tests de connectivité ==="
gcloud network-management connectivity-tests list

echo ""
echo "Résultats possibles :"
echo "  - REACHABLE    : Connectivité OK"
echo "  - UNREACHABLE  : Bloqué (firewall, route manquante, etc.)"
echo "  - AMBIGUOUS    : Résultat incertain"
echo "  - UNDETERMINED : Impossible à déterminer"
