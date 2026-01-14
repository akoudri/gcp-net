#!/bin/bash
# Lab 7.1 - Exercice 7.1.5 : Créer les Cloud Routers
# Objectif : Créer les Cloud Routers pour BGP

set -e

echo "=== Lab 7.1 - Exercice 5 : Créer les Cloud Routers ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Cloud Router pour VPC GCP (ASN 65001)
echo ">>> Création Cloud Router pour VPC GCP (ASN 65001)..."
gcloud compute routers create router-gcp \
    --network=vpc-gcp \
    --region=$REGION \
    --asn=65001 \
    --description="Cloud Router pour VPC GCP"

echo ""

# Cloud Router pour VPC On-premise (ASN 65002)
echo ">>> Création Cloud Router pour VPC On-premise (ASN 65002)..."
gcloud compute routers create router-onprem \
    --network=vpc-onprem \
    --region=$REGION \
    --asn=65002 \
    --description="Cloud Router pour VPC On-premise simulé"

echo ""

# Vérifier les Cloud Routers
echo "=== Cloud Routers créés ==="
gcloud compute routers list --filter="region:$REGION"
