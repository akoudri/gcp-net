#!/bin/bash
# Script pour supprimer toutes les ressources d'un VPC

# Vérifier si un nom de réseau est fourni
if [ $# -eq 0 ]; then
    echo "Usage: $0 <network-name>"
    echo "Exemple: $0 my-vpc-network"
    exit 1
fi

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
NETWORK="$1"

echo "=== Suppression des ressources du VPC $NETWORK ==="

# Fonction pour vérifier si une API est activée
check_api() {
    local api=$1
    gcloud services list --enabled --filter="name:$api" --format="value(name)" 2>/dev/null | grep -q "$api"
}

# 1. Clusters GKE (si l'API est activée)
if check_api "container.googleapis.com"; then
    echo "Suppression des clusters GKE..."
    gcloud container clusters list --format="value(name,zone)" 2>/dev/null | while read name zone; do
        if [ -n "$name" ] && [ -n "$zone" ]; then
            echo "  Suppression cluster: $name"
            gcloud container clusters delete $name --zone=$zone --quiet 2>/dev/null
        fi
    done
else
    echo "API Kubernetes Engine non activée, skip des clusters GKE..."
fi

# 2. Network Endpoint Groups
echo "Suppression des NEGs..."
gcloud compute network-endpoint-groups list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        # Vérifier si le NEG appartient au réseau
        neg_network=$(gcloud compute network-endpoint-groups describe $name --zone=$zone --format="value(network)" 2>/dev/null | grep -o "[^/]*$")
        if [ "$neg_network" = "$NETWORK" ]; then
            echo "  Suppression NEG: $name"
            gcloud compute network-endpoint-groups delete $name --zone=$zone --quiet 2>/dev/null
        fi
    fi
done

# 3. Instances
echo "Suppression des VMs..."
gcloud compute instances list --filter="networkInterfaces.network~$NETWORK" --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        echo "  Suppression VM: $name"
        gcloud compute instances delete $name --zone=$zone --quiet 2>/dev/null
    fi
done

# 4. Instance Groups
echo "Suppression des Instance Groups..."
gcloud compute instance-groups managed list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        # Vérifier si l'instance group appartient au réseau
        ig_network=$(gcloud compute instance-groups managed describe $name --zone=$zone --format="value(network)" 2>/dev/null | grep -o "[^/]*$")
        if [ "$ig_network" = "$NETWORK" ]; then
            echo "  Suppression MIG: $name"
            gcloud compute instance-groups managed delete $name --zone=$zone --quiet 2>/dev/null
        fi
    fi
done

gcloud compute instance-groups unmanaged list --format="value(name,zone)" 2>/dev/null | while read name zone; do
    if [ -n "$name" ] && [ -n "$zone" ]; then
        # Vérifier si l'instance group appartient au réseau
        ig_network=$(gcloud compute instance-groups unmanaged describe $name --zone=$zone --format="value(network)" 2>/dev/null | grep -o "[^/]*$")
        if [ "$ig_network" = "$NETWORK" ]; then
            echo "  Suppression UIG: $name"
            gcloud compute instance-groups unmanaged delete $name --zone=$zone --quiet 2>/dev/null
        fi
    fi
done

# 5. Forwarding Rules
echo "Suppression des Forwarding Rules..."
gcloud compute forwarding-rules list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ]; then
        # Vérifier si la forwarding rule appartient au réseau
        if [ -z "$region" ]; then
            fr_network=$(gcloud compute forwarding-rules describe $name --global --format="value(network)" 2>/dev/null | grep -o "[^/]*$")
            if [ "$fr_network" = "$NETWORK" ]; then
                echo "  Suppression Forwarding Rule (global): $name"
                gcloud compute forwarding-rules delete $name --global --quiet 2>/dev/null
            fi
        else
            fr_network=$(gcloud compute forwarding-rules describe $name --region=$region --format="value(network)" 2>/dev/null | grep -o "[^/]*$")
            if [ "$fr_network" = "$NETWORK" ]; then
                echo "  Suppression Forwarding Rule: $name"
                gcloud compute forwarding-rules delete $name --region=$region --quiet 2>/dev/null
            fi
        fi
    fi
done

# 6. Backend Services
echo "Suppression des Backend Services..."
gcloud compute backend-services list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ]; then
        echo "  Suppression Backend Service: $name"
        if [ -z "$region" ]; then
            gcloud compute backend-services delete $name --global --quiet 2>/dev/null
        else
            gcloud compute backend-services delete $name --region=$region --quiet 2>/dev/null
        fi
    fi
done

# 7. Health Checks
echo "Suppression des Health Checks..."
gcloud compute health-checks list --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Suppression Health Check: $name"
        gcloud compute health-checks delete $name --quiet 2>/dev/null
    fi
done

# 8. Cloud Routers (supprimer d'abord les NAT configs)
echo "Suppression des Cloud Routers..."
gcloud compute routers list --filter="network~$NETWORK" --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        # Supprimer les configurations NAT du routeur
        gcloud compute routers nats list --router=$name --region=$region --format="value(name)" 2>/dev/null | while read nat_name; do
            if [ -n "$nat_name" ]; then
                echo "  Suppression NAT config: $nat_name"
                gcloud compute routers nats delete $nat_name --router=$name --region=$region --quiet 2>/dev/null
            fi
        done
        echo "  Suppression Router: $name"
        gcloud compute routers delete $name --region=$region --quiet 2>/dev/null
    fi
done

# 9. VPN
echo "Suppression des VPN Tunnels..."
gcloud compute vpn-tunnels list --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Suppression VPN Tunnel: $name"
        gcloud compute vpn-tunnels delete $name --region=$region --quiet 2>/dev/null
    fi
done

echo "Suppression des VPN Gateways..."
gcloud compute vpn-gateways list --filter="network~$NETWORK" --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Suppression VPN Gateway: $name"
        gcloud compute vpn-gateways delete $name --region=$region --quiet 2>/dev/null
    fi
done

# 10. Firewall Rules
echo "Suppression des règles de pare-feu..."
gcloud compute firewall-rules list --filter="network~$NETWORK" --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ]; then
        echo "  Suppression Firewall: $name"
        gcloud compute firewall-rules delete $name --quiet 2>/dev/null
    fi
done

# 11. Routes (sauf default)
echo "Suppression des routes..."
gcloud compute routes list --filter="network~$NETWORK" --format="value(name)" 2>/dev/null | while read name; do
    if [ -n "$name" ] && [[ "$name" != "default-route-"* ]]; then
        echo "  Suppression Route: $name"
        gcloud compute routes delete $name --quiet 2>/dev/null
    fi
done

# 12. Subnets
echo "Suppression des sous-réseaux..."
gcloud compute networks subnets list --filter="network~$NETWORK" --format="value(name,region)" 2>/dev/null | while read name region; do
    if [ -n "$name" ] && [ -n "$region" ]; then
        echo "  Suppression Subnet: $name"
        gcloud compute networks subnets delete $name --region=$region --quiet 2>/dev/null
    fi
done

# 13. Enfin, le VPC
echo "Suppression du VPC $NETWORK..."
if gcloud compute networks describe $NETWORK &>/dev/null; then
    gcloud compute networks delete $NETWORK --quiet 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ VPC $NETWORK supprimé avec succès"
    else
        echo "✗ Échec de la suppression du VPC $NETWORK"
        echo "Vérifiez qu'il ne reste plus de ressources attachées"
    fi
else
    echo "Le VPC $NETWORK n'existe pas ou a déjà été supprimé"
fi

echo "=== Terminé ==="
