#!/bin/bash
# Lab 3.5 - Exercice 3.5.5 : Examiner les IPs NAT allouées
# Objectif : Observer les IPs publiques allouées automatiquement

set -e

echo "=== Lab 3.5 - Exercice 5 : Examiner les IPs NAT allouées ==="
echo ""

# Variables
export REGION_EU="europe-west1"

echo "Région : $REGION_EU"
echo ""

# Voir les IPs NAT automatiquement allouées
echo "=== IPs NAT allouées ==="
gcloud compute routers nats describe my-cloud-nat \
    --router=nat-router \
    --region=$REGION_EU \
    --format="yaml(natIps)"
echo ""

# Ou via le statut du router
echo "=== Mappings NAT ==="
gcloud compute routers get-nat-mapping-info nat-router \
    --region=$REGION_EU
echo ""
