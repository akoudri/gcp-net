#!/bin/bash
# Lab 5.6 - Exercice 5.6.4 : Créer le Service Attachment PSC
# Objectif : Publier le service via PSC

set -e

echo "=== Lab 5.6 - Exercice 4 : Créer le Service Attachment ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Créer le Service Attachment
echo "Création du Service Attachment PSC..."
gcloud compute service-attachments create my-service-attachment \
    --region=$REGION \
    --producer-forwarding-rule=ilb-producer \
    --connection-preference=ACCEPT_AUTOMATIC \
    --nat-subnets=subnet-psc-nat \
    --description="Service exposé via PSC"

echo ""
echo "Service Attachment créé avec succès !"
echo ""

# Vérifier
echo "=== Détails du Service Attachment ==="
gcloud compute service-attachments describe my-service-attachment \
    --region=$REGION

echo ""

# Récupérer l'URI du service attachment (nécessaire pour les consommateurs)
export SERVICE_ATTACHMENT_URI=$(gcloud compute service-attachments describe my-service-attachment \
    --region=$REGION \
    --format="get(selfLink)")

echo "=== Service Attachment créé ! ==="
echo ""
echo "Nom : my-service-attachment"
echo "Connection preference : ACCEPT_AUTOMATIC"
echo "NAT subnet : subnet-psc-nat"
echo ""
echo "URI du Service Attachment :"
echo "$SERVICE_ATTACHMENT_URI"
echo ""

# Sauvegarder l'URI pour les scripts suivants
echo "export SERVICE_ATTACHMENT_URI=\"$SERVICE_ATTACHMENT_URI\"" > /tmp/service-attachment-uri.env
echo "L'URI a été sauvegardée dans /tmp/service-attachment-uri.env"
echo ""

echo "Questions à considérer :"
echo ""
echo "1. Pourquoi avons-nous besoin d'un sous-réseau avec purpose=PRIVATE_SERVICE_CONNECT ?"
echo "   → Pour le NAT des connexions des consommateurs vers le producteur"
echo ""
echo "2. Quelle est la différence entre ACCEPT_AUTOMATIC et ACCEPT_MANUAL ?"
echo "   → ACCEPT_AUTOMATIC: Accepte automatiquement toutes les connexions"
echo "   → ACCEPT_MANUAL: Nécessite une approbation manuelle par connexion"
