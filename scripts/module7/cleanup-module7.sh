#!/bin/bash
# Nettoyage complet des ressources du Module 7
# Objectif : Supprimer toutes les ressources créées dans les labs

set -e

echo "=== Nettoyage des ressources du Module 7 ==="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

export REGION="europe-west1"
export ZONE="${REGION}-b"

echo ""
echo "=== Suppression des VMs ==="
for VM in vm-gcp vm-onprem vm-prod vm-paris vm-lyon vm-berlin; do
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des spokes NCC ==="
for SPOKE in spoke-paris spoke-lyon spoke-berlin; do
    gcloud network-connectivity spokes delete $SPOKE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression du hub NCC ==="
gcloud network-connectivity hubs delete hub-multisite --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des tunnels VPN ==="
for TUNNEL in $(gcloud compute vpn-tunnels list --format="get(name)" 2>/dev/null); do
    gcloud compute vpn-tunnels delete $TUNNEL --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des passerelles VPN ==="
for GW in $(gcloud compute vpn-gateways list --format="get(name)" 2>/dev/null); do
    gcloud compute vpn-gateways delete $GW --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des configurations Cloud NAT ==="
for ROUTER in $(gcloud compute routers list --format="get(name)" 2>/dev/null); do
    for NAT in $(gcloud compute routers nats list --router=$ROUTER --region=$REGION --format="get(name)" 2>/dev/null); do
        gcloud compute routers nats delete $NAT --router=$ROUTER --region=$REGION --quiet 2>/dev/null || true
    done
done

echo ""
echo "=== Suppression des Cloud Routers ==="
for ROUTER in $(gcloud compute routers list --format="get(name)" 2>/dev/null); do
    gcloud compute routers delete $ROUTER --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-gcp vpc-onprem vpc-hub-ncc vpc-site-paris vpc-site-lyon vpc-site-berlin vpc-production; do
    for RULE in $(gcloud compute firewall-rules list --filter="network:$VPC" --format="get(name)" 2>/dev/null); do
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
    done
done

echo ""
echo "=== Suppression des sous-réseaux ==="
for SUBNET in $(gcloud compute networks subnets list --filter="region:$REGION" --format="get(name)" 2>/dev/null); do
    # Skip default subnets
    if [[ ! "$SUBNET" =~ ^default ]]; then
        gcloud compute networks subnets delete $SUBNET --region=$REGION --quiet 2>/dev/null || true
    fi
done

echo ""
echo "=== Suppression des VPCs ==="
for VPC in vpc-gcp vpc-onprem vpc-hub-ncc vpc-site-paris vpc-site-lyon vpc-site-berlin vpc-production; do
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
echo ""
echo "Tunnels VPN restants :"
gcloud compute vpn-tunnels list 2>/dev/null || echo "Aucun tunnel VPN"
