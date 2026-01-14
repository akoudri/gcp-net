#!/bin/bash
# Lab 4.4 - Exercice 4.4.2 : Comprendre les rôles IAM Shared VPC
# Objectif : Explorer les rôles IAM nécessaires pour Shared VPC

set -e

echo "=== Lab 4.4 - Exercice 2 : Comprendre les rôles IAM Shared VPC ==="
echo ""

# Lister les rôles liés au Shared VPC
echo "=== Rôles liés au Shared VPC ==="
gcloud iam roles list --filter="name:compute.xpn" --format="table(name,title)"
echo ""

# Détails du rôle compute.xpnAdmin
echo "=== Détails du rôle compute.xpnAdmin ==="
echo "Ce rôle permet de gérer la configuration Shared VPC"
gcloud iam roles describe roles/compute.xpnAdmin --format="yaml(title,description,includedPermissions)"
echo ""

# Détails du rôle compute.networkAdmin
echo "=== Détails du rôle compute.networkAdmin ==="
echo "Ce rôle permet de gérer tous les aspects du réseau"
gcloud iam roles describe roles/compute.networkAdmin --format="yaml(title,description)" | head -10
echo "..."
echo ""

# Détails du rôle compute.networkUser
echo "=== Détails du rôle compute.networkUser ==="
echo "Ce rôle permet d'utiliser les ressources réseau partagées"
gcloud iam roles describe roles/compute.networkUser --format="yaml(title,description,includedPermissions)"
echo ""

echo "Résumé des rôles :"
echo "- compute.xpnAdmin      : Active/désactive Shared VPC, associe les projets de service"
echo "- compute.networkAdmin  : Gère les VPC, sous-réseaux, routes"
echo "- compute.networkUser   : Utilise les sous-réseaux partagés pour créer des VMs"
echo "- compute.securityAdmin : Gère les règles de pare-feu"
echo ""
