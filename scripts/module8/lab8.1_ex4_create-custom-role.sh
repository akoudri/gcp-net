#!/bin/bash
# Lab 8.1 - Exercice 8.1.4 : Créer un rôle personnalisé
# Objectif : Créer un rôle avec permissions limitées

set -e

echo "=== Lab 8.1 - Exercice 4 : Créer un rôle personnalisé ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)

echo "Projet : $PROJECT_ID"
echo ""

# Créer le fichier de définition du rôle
echo ">>> Création du fichier de définition du rôle..."
cat > /tmp/network-viewer-custom.yaml << 'EOF'
title: "Network Viewer Custom"
description: "Lecture réseau sans accès aux règles de pare-feu"
stage: "GA"
includedPermissions:
- compute.networks.get
- compute.networks.list
- compute.subnetworks.get
- compute.subnetworks.list
- compute.routes.get
- compute.routes.list
EOF

echo "Fichier créé : /tmp/network-viewer-custom.yaml"
echo ""

# Créer le rôle personnalisé
echo ">>> Création du rôle personnalisé..."
gcloud iam roles create NetworkViewerCustom \
    --project=$PROJECT_ID \
    --file=/tmp/network-viewer-custom.yaml

echo ""
echo "Rôle créé avec succès !"
echo ""

# Afficher le rôle
echo ">>> Détails du rôle créé..."
gcloud iam roles describe NetworkViewerCustom --project=$PROJECT_ID

echo ""
echo "Pour attribuer ce rôle à un utilisateur :"
echo "gcloud projects add-iam-policy-binding \$PROJECT_ID \\"
echo "    --member=\"user:auditor@example.com\" \\"
echo "    --role=\"projects/\$PROJECT_ID/roles/NetworkViewerCustom\""
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi ce rôle n'inclut pas compute.firewalls.* ?"
echo "2. Quand créer un rôle personnalisé plutôt qu'utiliser un rôle prédéfini ?"
echo "3. Comment maintenir les rôles personnalisés à jour ?"
