#!/bin/bash
# Lab 10.12 : Scénario intégrateur - Architecture multi-tier
# Objectif : Récapitulatif de l'architecture complète déployée

set -e

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=========================================="
echo "  DÉPLOIEMENT ARCHITECTURE MULTI-TIER"
echo "=========================================="
echo ""

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)" 2>/dev/null || echo "Non configuré")

echo "Architecture déployée :"
echo ""
echo "1. GLOBAL EXTERNAL APPLICATION LB"
echo "   - Frontend : http://$LB_IP"
echo "   - Cloud CDN : Activé sur /static/*"
echo "   - Routage intelligent par URL"
echo ""
echo "2. INTERNAL APPLICATION LB"
echo "   - IP : 10.0.2.100"
echo "   - Services : /users, /orders, /default"
echo "   - Uniquement accessible depuis le VPC"
echo ""
echo "3. INTERNAL NETWORK LB"
echo "   - IP : 10.0.3.100:5432"
echo "   - Backend : Cluster de base de données"
echo "   - Passthrough pour performance maximale"
echo ""
echo "Composants :"
echo "- Instance Groups frontend (web, api)"
echo "- Instance Groups backend (users, orders, default)"
echo "- Instance Groups database (ig-db)"
echo "- Cloud Storage pour contenu statique"
echo "- Health checks HTTP et TCP"
echo ""

echo "=== État des backends globaux ==="
for BACKEND in backend-web backend-api backend-v1 backend-v2; do
    echo ""
    echo "--- $BACKEND ---"
    gcloud compute backend-services get-health $BACKEND --global 2>/dev/null || echo "Non configuré ou non global"
done

echo ""
echo ""
echo "=== État des backends régionaux ==="
for BACKEND in backend-users backend-orders backend-default backend-db; do
    echo ""
    echo "--- $BACKEND ---"
    gcloud compute backend-services get-health $BACKEND --region=$REGION 2>/dev/null || echo "Non configuré"
done

echo ""
echo ""
echo "=== Ressources créées ==="
echo ""
echo "VPCs et Sous-réseaux :"
gcloud compute networks list --filter="name:vpc-lb-lab"
gcloud compute networks subnets list --filter="network:vpc-lb-lab" --format="table(name,region,ipCidrRange)"

echo ""
echo "Instance Groups :"
gcloud compute instance-groups managed list --filter="name~(ig-.*)" --format="table(name,zone,size)"

echo ""
echo "Backend Services :"
gcloud compute backend-services list --format="table(name,loadBalancingScheme,protocol)"

echo ""
echo "URL Maps :"
gcloud compute url-maps list --format="table(name,defaultService)"

echo ""
echo "Forwarding Rules :"
gcloud compute forwarding-rules list --format="table(name,IPAddress,target)"

echo ""
echo "=========================================="
echo "  ARCHITECTURE COMPLÈTE DÉPLOYÉE"
echo "=========================================="
