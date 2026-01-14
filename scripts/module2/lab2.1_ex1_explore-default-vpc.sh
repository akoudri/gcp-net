#!/bin/bash
# Lab 2.1 - Exercice 2.1.1 : Explorer le VPC default
# Objectif : Découvrir la structure du VPC par défaut

set -e

echo "=== Lab 2.1 - Exercice 1 : Explorer le VPC default ==="
echo ""

# Définir le projet
export PROJECT_ID=$(gcloud config get-value project)
echo "Projet actif : $PROJECT_ID"
echo ""

# Lister tous les VPC du projet
echo "=== Liste des VPC ==="
gcloud compute networks list
echo ""

# Examiner les détails du VPC default
echo "=== Détails du VPC default ==="
gcloud compute networks describe default
echo ""

# Lister les sous-réseaux du VPC default
echo "=== Sous-réseaux du VPC default ==="
gcloud compute networks subnets list --network=default
echo ""

echo "Questions à considérer :"
echo "1. Combien de sous-réseaux le VPC default possède-t-il ?"
echo "2. Quelle est la plage IP du sous-réseau dans europe-west1 ?"
echo "3. Quel est le mode de création du VPC default (auto ou custom) ?"
