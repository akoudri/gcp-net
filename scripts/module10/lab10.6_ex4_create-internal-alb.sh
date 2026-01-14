#!/bin/bash
# Lab 10.6 - Exercice 10.6.4 : Créer l'Internal Application LB
# Objectif : Créer tous les composants de l'Internal Application Load Balancer

set -e

echo "=== Lab 10.6 - Exercice 4 : Créer l'Internal Application LB ==="
echo ""

# Variables
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Health check régional
echo "Création du health check régional..."
gcloud compute health-checks create http hc-internal \
    --port=80 \
    --request-path="/health" \
    --region=$REGION

echo ""
echo "Création des backend services régionaux..."

# Backend services régionaux
for SERVICE in users orders default; do
    echo ""
    echo "Création de backend-${SERVICE}..."
    gcloud compute backend-services create backend-${SERVICE} \
        --protocol=HTTP \
        --port-name=http \
        --health-checks=hc-internal \
        --health-checks-region=$REGION \
        --load-balancing-scheme=INTERNAL_MANAGED \
        --region=$REGION

    echo "Ajout de ig-${SERVICE} au backend..."
    gcloud compute backend-services add-backend backend-${SERVICE} \
        --instance-group=ig-${SERVICE} \
        --instance-group-zone=$ZONE \
        --region=$REGION
done

echo ""
echo "Création de l'URL Map régional..."

# URL Map régional
gcloud compute url-maps create urlmap-internal \
    --default-service=backend-default \
    --region=$REGION

echo ""
echo "Ajout des path matchers..."

gcloud compute url-maps add-path-matcher urlmap-internal \
    --path-matcher-name=services \
    --default-service=backend-default \
    --path-rules="/users/*=backend-users,/orders/*=backend-orders" \
    --region=$REGION

gcloud compute url-maps add-host-rule urlmap-internal \
    --hosts="*" \
    --path-matcher-name=services \
    --region=$REGION

echo ""
echo "Création du target proxy régional..."

# Target proxy régional
gcloud compute target-http-proxies create proxy-internal \
    --url-map=urlmap-internal \
    --url-map-region=$REGION \
    --region=$REGION

echo ""
echo "Création de la forwarding rule avec IP interne..."

# Forwarding rule avec IP interne
gcloud compute forwarding-rules create fr-internal \
    --load-balancing-scheme=INTERNAL_MANAGED \
    --network=vpc-lb-lab \
    --subnet=subnet-internal \
    --address=10.0.2.100 \
    --target-http-proxy=proxy-internal \
    --target-http-proxy-region=$REGION \
    --ports=80 \
    --region=$REGION

echo ""
echo "Internal Application LB créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "IP Interne : 10.0.2.100"
echo "URL Map : urlmap-internal"
echo "Règles de routage :"
echo "  - /users/* → backend-users"
echo "  - /orders/* → backend-orders"
echo "  - /* (défaut) → backend-default"
echo ""
echo "Pour tester, créez une VM client dans le même VPC."
