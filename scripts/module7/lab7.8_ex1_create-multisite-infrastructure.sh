#!/bin/bash
# Lab 7.8 - Exercice 7.8.1 : Créer l'infrastructure multi-sites
# Objectif : Créer le VPC hub et les VPC des sites pour Network Connectivity Center

set -e

echo "=== Lab 7.8 - Exercice 1 : Créer l'infrastructure multi-sites ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

# Créer le VPC central (Hub)
echo ">>> Création du VPC Hub NCC..."
gcloud compute networks create vpc-hub-ncc \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-hub \
    --network=vpc-hub-ncc \
    --region=$REGION \
    --range=10.0.0.0/24

echo ""

# Créer les VPC des sites (simulés)
echo ">>> Création des VPCs des sites..."
for SITE in paris lyon berlin; do
    case $SITE in
        paris)  RANGE="10.1.0.0/24" ;;
        lyon)   RANGE="10.2.0.0/24" ;;
        berlin) RANGE="10.3.0.0/24" ;;
    esac

    echo "  - Création VPC site $SITE ($RANGE)"
    gcloud compute networks create vpc-site-${SITE} \
        --subnet-mode=custom

    gcloud compute networks subnets create subnet-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --range=$RANGE

    gcloud compute firewall-rules create vpc-site-${SITE}-allow-all \
        --network=vpc-site-${SITE} \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8

    gcloud compute firewall-rules create vpc-site-${SITE}-allow-ssh \
        --network=vpc-site-${SITE} \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20
done

echo ""
echo "=== Infrastructure multi-sites créée ==="
echo ""
echo "Réseaux créés :"
gcloud compute networks list --filter="name:(vpc-hub-ncc OR vpc-site-)"
