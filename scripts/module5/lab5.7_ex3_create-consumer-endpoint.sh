#!/bin/bash
# Lab 5.7 - Exercice 5.7.3 : Créer l'endpoint PSC vers le service du producteur
# Objectif : Connecter le consommateur au service du producteur

set -e

echo "=== Lab 5.7 - Exercice 3 : Créer l'endpoint PSC consommateur ==="
echo ""

export VPC_CONSUMER="vpc-consumer"
export REGION="europe-west1"

# Récupérer l'URI du service attachment
if [ -f /tmp/service-attachment-uri.env ]; then
    source /tmp/service-attachment-uri.env
else
    echo "ERREUR: URI du Service Attachment non trouvée."
    echo "Exécutez d'abord lab5.6_ex4_create-service-attachment.sh"
    exit 1
fi

echo "VPC : $VPC_CONSUMER"
echo "Région : $REGION"
echo ""
echo "Service Attachment URI :"
echo "$SERVICE_ATTACHMENT_URI"
echo ""

# Créer la forwarding rule PSC vers le Service Attachment
echo "Création de l'endpoint PSC vers le service du producteur..."
gcloud compute forwarding-rules create psc-to-producer \
    --region=$REGION \
    --network=$VPC_CONSUMER \
    --address=psc-consumer-endpoint \
    --target-service-attachment=$SERVICE_ATTACHMENT_URI

echo ""
echo "Endpoint PSC créé avec succès !"
echo ""

# Vérifier
echo "=== Détails de l'endpoint PSC ==="
gcloud compute forwarding-rules describe psc-to-producer --region=$REGION

echo ""

# Voir l'état de la connexion côté producteur
echo "=== État de la connexion côté producteur ==="
gcloud compute service-attachments describe my-service-attachment \
    --region=$REGION \
    --format="yaml(connectedEndpoints)"

echo ""
echo "=== Endpoint consommateur créé ! ==="
echo ""
echo "IP endpoint : 10.60.0.100"
echo "Cible : Service du producteur via PSC"
echo ""
echo "Le consommateur peut maintenant accéder au service via 10.60.0.100"
