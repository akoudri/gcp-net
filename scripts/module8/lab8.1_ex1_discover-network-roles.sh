#!/bin/bash
# Lab 8.1 - Exercice 8.1.1 : Découvrir les rôles réseau
# Objectif : Comprendre les rôles IAM réseau disponibles

set -e

echo "=== Lab 8.1 - Exercice 1 : Découvrir les rôles réseau ==="
echo ""

# Lister les rôles réseau disponibles
echo ">>> Rôles réseau disponibles..."
gcloud iam roles list --filter="name:compute.network" --format="table(name,title)"

echo ""
echo ">>> Détail du rôle networkAdmin..."
gcloud iam roles describe roles/compute.networkAdmin

echo ""
echo ">>> Permissions du rôle networkAdmin..."
gcloud iam roles describe roles/compute.networkAdmin \
    --format="yaml(includedPermissions)"

echo ""
echo "Questions à considérer :"
echo "1. Quelles sont les différences entre networkAdmin, networkUser et securityAdmin ?"
echo "2. Dans quel cas utiliser networkViewer ?"
echo "3. Qu'est-ce que le rôle xpnAdmin ?"
