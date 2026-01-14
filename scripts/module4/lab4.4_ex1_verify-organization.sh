#!/bin/bash
# Lab 4.4 - Exercice 4.4.1 : Vérifier l'appartenance à une organisation
# Objectif : Vérifier si le projet appartient à une organisation GCP

set -e

echo "=== Lab 4.4 - Exercice 1 : Vérifier l'appartenance à une organisation ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Vérifier si le projet appartient à une organisation
echo "=== Vérification de l'organisation ==="
PARENT_INFO=$(gcloud projects describe $PROJECT_ID \
    --format="get(parent.type,parent.id)" 2>/dev/null || echo "none none")

PARENT_TYPE=$(echo $PARENT_INFO | awk '{print $1}')
PARENT_ID=$(echo $PARENT_INFO | awk '{print $2}')

echo "Type de parent : $PARENT_TYPE"
echo "ID du parent : $PARENT_ID"
echo ""

if [ "$PARENT_TYPE" = "organization" ]; then
    echo "✓ Ce projet appartient à une organisation GCP"
    echo "  Organisation ID : $PARENT_ID"
    echo ""
    echo "Shared VPC est POSSIBLE dans cet environnement."
elif [ "$PARENT_TYPE" = "folder" ]; then
    echo "✓ Ce projet est dans un dossier"
    echo "  Folder ID : $PARENT_ID"
    echo ""
    echo "Shared VPC est POSSIBLE (le dossier appartient à une organisation)."
else
    echo "✗ Ce projet n'appartient pas à une organisation"
    echo ""
    echo "⚠️  Shared VPC nécessite une organisation GCP."
    echo "   Consultez le Lab 4.6 pour une simulation sans organisation."
fi

echo ""

# Lister les organisations accessibles
echo "=== Organisations accessibles ==="
gcloud organizations list 2>/dev/null || echo "Aucune organisation accessible ou pas de permissions"

echo ""
