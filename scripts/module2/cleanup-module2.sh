#!/bin/bash
# Nettoyage complet des ressources du Module 2
# Objectif : Supprimer toutes les ressources créées dans les labs

set -e

echo "=== Nettoyage des ressources du Module 2 ==="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

echo ""
echo "=== Suppression des Connectivity Tests ==="
gcloud network-management connectivity-tests delete test-web-to-api --quiet 2>/dev/null || true
gcloud network-management connectivity-tests delete test-vm-to-vm --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des VMs ==="
# Lab 2.1 & 2.2
gcloud compute instances delete test-default-vpc --zone=europe-west1-b --quiet 2>/dev/null || true
gcloud compute instances delete vm-eu --zone=europe-west1-b --quiet 2>/dev/null || true
gcloud compute instances delete vm-us --zone=us-central1-a --quiet 2>/dev/null || true

# Lab 2.4
gcloud compute instances delete appliance-vm client-a client-b --zone=europe-west1-b --quiet 2>/dev/null || true

# Lab 2.5
gcloud compute instances delete vm-premium vm-standard --zone=europe-west1-b --quiet 2>/dev/null || true

# Lab 2.7
gcloud compute instances delete bastion web-prod api-prod dev-vm --zone=europe-west1-b --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des routes personnalisées ==="
gcloud compute routes delete route-a-to-b --quiet 2>/dev/null || true
gcloud compute routes delete route-b-to-a --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des adresses IP ==="
gcloud compute addresses delete ip-standard --region=europe-west1 --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des Cloud NAT ==="
for ROUTER in router-nat router-nat-eu router-nat-us router-regional router-global; do
    for REGION in europe-west1 us-central1; do
        NATS=$(gcloud compute routers nats list --router=$ROUTER --region=$REGION --format="get(name)" 2>/dev/null || true)
        for NAT in $NATS; do
            gcloud compute routers nats delete $NAT --router=$ROUTER --region=$REGION --quiet 2>/dev/null || true
        done
    done
done

echo ""
echo "=== Suppression des Cloud Routers ==="
for ROUTER in router-nat router-nat-eu router-nat-us router-regional router-global; do
    for REGION in europe-west1 us-central1; do
        gcloud compute routers delete $ROUTER --region=$REGION --quiet 2>/dev/null || true
    done
done

echo ""
echo "=== Suppression des règles de pare-feu ==="
FIREWALLS=$(gcloud compute firewall-rules list --format="get(name)" | grep -E "(production-vpc|planning-vpc|vpc-a|vpc-b|tier-test|vpc-regional|vpc-global|startup-vpc)" || true)
for RULE in $FIREWALLS; do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des sous-réseaux ==="
SUBNETS=$(gcloud compute networks subnets list --format="get(name,region)" | grep -E "(subnet-eu|subnet-us|subnet-prod|subnet-dev|subnet-mgmt|subnet-small|subnet-a|subnet-b|tier-test)" || true)
while IFS= read -r line; do
    NAME=$(echo $line | awk '{print $1}')
    REGION=$(echo $line | awk '{print $2}')
    gcloud compute networks subnets delete $NAME --region=$REGION --quiet 2>/dev/null || true
done <<< "$SUBNETS"

echo ""
echo "=== Suppression des VPCs ==="
for VPC in production-vpc planning-vpc vpc-a vpc-b tier-test-vpc vpc-regional vpc-global startup-vpc; do
    gcloud compute networks delete $VPC --quiet 2>/dev/null || true
done

echo ""
echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""
echo "VPCs restants :"
gcloud compute networks list
echo ""
echo "VMs restantes :"
gcloud compute instances list
