#!/bin/bash
# Lab 5.6 - Exercice 5.6.3 : Créer l'Internal Load Balancer
# Objectif : Créer un ILB pour le backend

set -e

echo "=== Lab 5.6 - Exercice 3 : Créer l'Internal Load Balancer ==="
echo ""

export VPC_PRODUCER="vpc-producer"
export REGION="europe-west1"
export ZONE="europe-west1-b"

echo "VPC : $VPC_PRODUCER"
echo "Région : $REGION"
echo ""

# Health check
echo "Création du health check..."
gcloud compute health-checks create http hc-backend \
    --port=80 \
    --request-path=/

echo ""

# Backend service
echo "Création du backend service..."
gcloud compute backend-services create backend-service \
    --load-balancing-scheme=INTERNAL \
    --protocol=TCP \
    --region=$REGION \
    --health-checks=hc-backend \
    --health-checks-region=$REGION

gcloud compute backend-services add-backend backend-service \
    --region=$REGION \
    --instance-group=backend-group \
    --instance-group-zone=$ZONE

echo ""

# Forwarding rule (Internal LB)
echo "Création de la forwarding rule (ILB)..."
gcloud compute forwarding-rules create ilb-producer \
    --region=$REGION \
    --load-balancing-scheme=INTERNAL \
    --network=$VPC_PRODUCER \
    --subnet=subnet-producer \
    --address=10.50.0.100 \
    --ip-protocol=TCP \
    --ports=80 \
    --backend-service=backend-service \
    --backend-service-region=$REGION

echo ""
echo "Internal Load Balancer créé !"
echo ""

# Vérifier
echo "=== Détails de l'ILB ==="
gcloud compute forwarding-rules describe ilb-producer --region=$REGION

echo ""
echo "=== ILB créé avec succès ! ==="
echo ""
echo "IP du Load Balancer : 10.50.0.100"
echo "Backend : backend-vm via backend-group"
echo "Health check : HTTP sur port 80"
