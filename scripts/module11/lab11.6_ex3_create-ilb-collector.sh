#!/bin/bash
# Lab 11.6 - Exercice 11.6.3 : Créer l'Internal Load Balancer (collecteur)
# Objectif : Configurer l'ILB pour recevoir le trafic mirroré

set -e

echo "=== Lab 11.6 - Exercice 3 : Créer l'Internal Load Balancer ==="
echo ""

# Variables
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Région : $REGION"
echo ""

# Health check pour le collecteur
echo "Création du health check..."
gcloud compute health-checks create tcp hc-collector \
    --port=4789 \
    --region=$REGION

echo ""
echo "Health check créé !"
echo ""

# Backend service pour le collecteur
echo "Création du backend service..."
gcloud compute backend-services create collector-backend \
    --protocol=UDP \
    --health-checks=hc-collector \
    --health-checks-region=$REGION \
    --load-balancing-scheme=INTERNAL \
    --region=$REGION

echo ""
echo "Backend service créé !"
echo ""

# Ajouter le groupe d'instances
echo "Ajout du groupe d'instances au backend..."
gcloud compute backend-services add-backend collector-backend \
    --instance-group=ig-collector \
    --instance-group-zone=$ZONE \
    --region=$REGION

echo ""
echo "Groupe d'instances ajouté au backend !"
echo ""

# Forwarding rule pour le collecteur (avec flag is-mirroring-collector)
echo "Création de la forwarding rule pour le mirroring..."
gcloud compute forwarding-rules create collector-ilb \
    --load-balancing-scheme=INTERNAL \
    --network=vpc-observability \
    --subnet=subnet-collector \
    --backend-service=collector-backend \
    --is-mirroring-collector \
    --ports=ALL \
    --region=$REGION

echo ""
echo "=== ILB Collecteur créé avec succès ==="
echo ""

# Afficher les détails
gcloud compute forwarding-rules describe collector-ilb \
    --region=$REGION

echo ""
echo "L'ILB est maintenant prêt à recevoir le trafic mirroré."
