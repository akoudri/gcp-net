#!/bin/bash
# Lab 11.9 - Exercice 11.9.1 : Créer un canal de notification
# Objectif : Créer un canal email pour les alertes

set -e

echo "=== Lab 11.9 - Exercice 1 : Créer un canal de notification ==="
echo ""

echo "Entrez l'adresse email pour les notifications :"
read -p "Email : " EMAIL_ADDRESS

if [ -z "$EMAIL_ADDRESS" ]; then
    echo "Utilisation de l'email par défaut : ops@example.com"
    EMAIL_ADDRESS="ops@example.com"
fi

echo ""
echo "Création du canal de notification email..."

# Créer un canal email
gcloud alpha monitoring channels create \
    --display-name="Network Ops Email" \
    --type=email \
    --channel-labels=email_address=$EMAIL_ADDRESS

echo ""
echo "Canal de notification créé avec succès !"
echo ""

# Lister les canaux
echo "=== Canaux de notification disponibles ==="
gcloud alpha monitoring channels list

echo ""

# Récupérer l'ID du canal
CHANNEL_ID=$(gcloud alpha monitoring channels list --format="get(name)" | head -1)
echo "Canal ID principal : $CHANNEL_ID"
echo ""
echo "Utilisez ce Channel ID dans les politiques d'alerte."
