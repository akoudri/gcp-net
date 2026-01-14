#!/bin/bash
# Lab 8.8 - Exercice 8.8.1 : Activer l'API et créer l'endpoint IDS
# Objectif : Déployer Cloud IDS pour la détection d'intrusion
# ATTENTION : Cloud IDS a un coût significatif (~$1.50/heure)

set -e

echo "=== Lab 8.8 - Exercice 1 : Créer l'endpoint Cloud IDS ==="
echo ""
echo "⚠️  ATTENTION : Cloud IDS a un coût significatif (~$1.50/heure par endpoint)."
echo "⚠️  Pensez à le supprimer après le lab avec lab8.8_ex5_cleanup-ids.sh"
echo ""

read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Création annulée."
    exit 0
fi

export VPC_NAME="vpc-security-lab"
export ZONE="europe-west1-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# Activer l'API
echo ">>> Activation de l'API Cloud IDS..."
gcloud services enable ids.googleapis.com

echo ""
echo "API activée !"
echo ""

# Créer l'endpoint Cloud IDS
echo ">>> Création de l'endpoint Cloud IDS..."
echo "IMPORTANT : Cela peut prendre 15-30 minutes."
echo ""

gcloud ids endpoints create ids-endpoint-lab \
    --zone=$ZONE \
    --network=$VPC_NAME \
    --severity=INFORMATIONAL \
    --description="Endpoint IDS pour le lab" \
    --async

echo ""
echo "Création de l'endpoint lancée (mode asynchrone)."
echo ""

# Vérifier le statut
echo ">>> Vérification du statut de création..."
gcloud ids endpoints describe ids-endpoint-lab --zone=$ZONE

echo ""
echo "=== Instructions ==="
echo ""
echo "L'endpoint est en cours de création. Pour suivre la progression :"
echo ""
echo "watch -n 30 \"gcloud ids endpoints describe ids-endpoint-lab --zone=$ZONE --format='get(state)'\""
echo ""
echo "Attendez que le statut soit 'READY' avant de continuer avec le lab suivant."
echo ""
echo "États possibles :"
echo "  - CREATING: En cours de création"
echo "  - READY: Prêt à utiliser"
echo "  - FAILED: Échec de création"
echo ""

echo "Questions à considérer :"
echo "1. Pourquoi Cloud IDS nécessite-t-il autant de temps pour se déployer ?"
echo "2. Quels types de menaces Cloud IDS peut-il détecter ?"
echo "3. Comment Cloud IDS se compare-t-il à un IDS traditionnel sur site ?"
