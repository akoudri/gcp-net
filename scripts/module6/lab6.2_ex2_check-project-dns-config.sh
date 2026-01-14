#!/bin/bash
# Lab 6.2 - Exercice 6.2.2 : Vérifier la configuration DNS du projet
# Objectif : Voir la configuration DNS actuelle

set -e

echo "=== Lab 6.2 - Exercice 2 : Vérifier la configuration DNS du projet ==="
echo ""

# Voir la configuration DNS actuelle du projet
echo "Configuration DNS du projet :"
gcloud compute project-info describe \
    --format="get(vmDnsSetting)"
echo ""

echo "Résultat possible :"
echo "- ZONAL_ONLY : DNS zonal (recommandé)"
echo "- GLOBAL_DEFAULT : DNS global (ancien comportement)"
echo "- Vide : Configuration par défaut"
