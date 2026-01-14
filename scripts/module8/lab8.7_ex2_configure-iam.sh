#!/bin/bash
# Lab 8.7 - Exercice 8.7.2 : Configurer les permissions IAM
# Objectif : Configurer les permissions IAP pour les utilisateurs

set -e

echo "=== Lab 8.7 - Exercice 2 : Configurer les permissions IAM pour IAP ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)
export ZONE="europe-west1-b"

echo "Projet : $PROJECT_ID"
echo "Zone : $ZONE"
echo ""

echo "IMPORTANT : Ce script montre comment configurer les permissions IAP."
echo "Remplacez 'admin@example.com' par l'email de l'utilisateur réel."
echo ""

# Exemple de configuration au niveau projet (commenté pour éviter erreurs)
echo "=== Configuration au niveau projet ==="
echo ""
echo "Pour donner accès IAP à tous les utilisateurs du projet :"
echo ""
echo "gcloud projects add-iam-policy-binding \$PROJECT_ID \\"
echo "    --member=\"user:admin@example.com\" \\"
echo "    --role=\"roles/iap.tunnelResourceAccessor\""
echo ""

# Exemple de configuration granulaire sur une VM
echo "=== Configuration granulaire sur une VM ==="
echo ""
echo "Pour donner accès IAP uniquement à une VM spécifique :"
echo ""
echo "gcloud compute instances add-iam-policy-binding vm-api-sa \\"
echo "    --zone=\$ZONE \\"
echo "    --member=\"user:admin@example.com\" \\"
echo "    --role=\"roles/iap.tunnelResourceAccessor\""
echo ""

# Afficher les permissions actuelles d'une VM
if gcloud compute instances describe vm-api-sa --zone=$ZONE &>/dev/null; then
    echo "=== Permissions IAM actuelles de vm-api-sa ==="
    gcloud compute instances get-iam-policy vm-api-sa --zone=$ZONE
else
    echo "AVERTISSEMENT : vm-api-sa n'existe pas. Créez-la avec lab8.3_ex4_create-vms-with-sa.sh"
fi

echo ""
echo "=== Rôles IAP disponibles ==="
echo ""
echo "┌────────────────────────────────────┬───────────────────────────────────┐"
echo "│ Rôle                               │ Description                       │"
echo "├────────────────────────────────────┼───────────────────────────────────┤"
echo "│ roles/iap.tunnelResourceAccessor   │ Accès aux ressources via IAP      │"
echo "│ roles/iap.tunnelInstanceAccessor   │ Accès aux instances via IAP       │"
echo "│ roles/iap.admin                    │ Administration IAP                │"
echo "└────────────────────────────────────┴───────────────────────────────────┘"
echo ""

echo "Questions à considérer :"
echo "1. Quelle est la différence entre tunnelResourceAccessor et tunnelInstanceAccessor ?"
echo "2. Pourquoi est-il préférable d'accorder les permissions au niveau instance ?"
echo "3. Comment révoquer l'accès IAP d'un utilisateur ?"
