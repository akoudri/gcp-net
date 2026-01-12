#!/bin/bash
# Script pour supprimer toutes les ressources du VPC default

PROJECT_ID=$(gcloud config get-value project)
NETWORK="default"

echo "=== Suppression des ressources du VPC $NETWORK ==="

# 1. Clusters GKE
echo "Suppression des clusters GKE..."
gcloud container clusters list --format="value(name,zone)" | while read name zone; do
    echo "  Suppression cluster: $name"
    gcloud container clusters delete $name --zone=$zone --quiet 2>/dev/null
done

# 2. Network Endpoint Groups
echo "Suppression des NEGs..."
gcloud compute network-endpoint-groups list --filter="network~$NETWORK" --format="value(name,zone)" | while read name zone; do
    echo "  Suppression NEG: $name"
    gcloud compute network-endpoint-groups delete $name --zone=$zone --quiet 2>/dev/null
done

# 3. Instances
echo "Suppression des VMs..."
gcloud compute instances list --filter="networkInterfaces.network~$NETWORK" --format="value(name,zone)" | while read name zone; do
    echo "  Suppression VM: $name"
    gcloud compute instances delete $name --zone=$zone --quiet 2>/dev/null
done

# 4. Instance Groups
echo "Suppression des Instance Groups..."
gcloud compute instance-groups managed list --filter="network~$NETWORK" --format="value(name,zone)" | while read name zone; do
    echo "  Suppression MIG: $name"
    gcloud compute instance-groups managed delete $name --zone=$zone --quiet 2>/dev/null
done

gcloud compute instance-groups unmanaged list --filter="network~$NETWORK" --format="value(name,zone)" | while read name zone; do
    echo "  Suppression UIG: $name"
    gcloud compute instance-groups unmanaged delete $name --zone=$zone --quiet 2>/dev/null
done

# 5. Forwarding Rules
echo "Suppression des Forwarding Rules..."
gcloud compute forwarding-rules list --filter="network~$NETWORK" --format="value(name,region)" | while read name region; do
    echo "  Suppression Forwarding Rule: $name"
    if [ -z "$region" ]; then
        gcloud compute forwarding-rules delete $name --global --quiet 2>/dev/null
    else
        gcloud compute forwarding-rules delete $name --region=$region --quiet 2>/dev/null
    fi
done

# 6. Backend Services
echo "Suppression des Backend Services..."
gcloud compute backend-services list --format="value(name,region)" | while read name region; do
    echo "  Suppression Backend Service: $name"
    if [ -z "$region" ]; then
        gcloud compute backend-services delete $name --global --quiet 2>/dev/null
    else
        gcloud compute backend-services delete $name --region=$region --quiet 2>/dev/null
    fi
done

# 7. Health Checks
echo "Suppression des Health Checks..."
gcloud compute health-checks list --format="value(name)" | while read name; do
    echo "  Suppression Health Check: $name"
    gcloud compute health-checks delete $name --quiet 2>/dev/null
done

# 8. Cloud Routers
echo "Suppression des Cloud Routers..."
gcloud compute routers list --filter="network~$NETWORK" --format="value(name,region)" | while read name region; do
    echo "  Suppression Router: $name"
    gcloud compute routers delete $name --region=$region --quiet 2>/dev/null
done

# 9. VPN
echo "Suppression des VPN..."
gcloud compute vpn-tunnels list --format="value(name,region)" | while read name region; do
    echo "  Suppression VPN Tunnel: $name"
    gcloud compute vpn-tunnels delete $name --region=$region --quiet 2>/dev/null
done

gcloud compute vpn-gateways list --filter="network~$NETWORK" --format="value(name,region)" | while read name region; do
    echo "  Suppression VPN Gateway: $name"
    gcloud compute vpn-gateways delete $name --region=$region --quiet 2>/dev/null
done

# 10. Firewall Rules
echo "Suppression des règles de pare-feu..."
gcloud compute firewall-rules list --filter="network~$NETWORK" --format="value(name)" | while read name; do
    echo "  Suppression Firewall: $name"
    gcloud compute firewall-rules delete $name --quiet 2>/dev/null
done

# 11. Routes (sauf default)
echo "Suppression des routes..."
gcloud compute routes list --filter="network~$NETWORK" --format="value(name)" | while read name; do
    if [[ "$name" != "default-route-"* ]]; then
        echo "  Suppression Route: $name"
        gcloud compute routes delete $name --quiet 2>/dev/null
    fi
done

# 12. Subnets
echo "Suppression des sous-réseaux..."
gcloud compute networks subnets list --filter="network~$NETWORK" --format="value(name,region)" | while read name region; do
    echo "  Suppression Subnet: $name"
    gcloud compute networks subnets delete $name --region=$region --quiet 2>/dev/null
done

# 13. Enfin, le VPC
echo "Suppression du VPC $NETWORK..."
gcloud compute networks delete $NETWORK --quiet

echo "=== Terminé ==="
