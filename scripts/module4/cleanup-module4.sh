#!/bin/bash
# Nettoyage complet des ressources du Module 4
# Objectif : Supprimer toutes les ressources créées dans les labs VPC Peering et Shared VPC

set -e

echo "=== Nettoyage des ressources du Module 4 ==="
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
echo "Début du nettoyage..."
echo ""

# Variables
REGION="europe-west1"
ZONE="${REGION}-b"

# =====================================================
# Étape 1 : Suppression des VMs
# =====================================================
echo "=== Suppression des VMs ==="

# Lab 4.1 & 4.2 (VPC Peering)
for VM in vm-alpha vm-beta vm-gamma; do
    echo "  - $VM"
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

# Lab 4.6 (Shared VPC Simulation)
for VM in vm-frontend vm-backend vm-database; do
    echo "  - $VM"
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

# Lab 4.9 (Architecture Hybride)
for VM in vm-prod vm-staging vm-dev vm-partner; do
    echo "  - $VM"
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

echo ""

# =====================================================
# Étape 2 : Suppression des peerings
# =====================================================
echo "=== Suppression des peerings ==="

for VPC in vpc-alpha vpc-beta vpc-gamma vpc-hub vpc-partner; do
    PEERINGS=$(gcloud compute networks peerings list --network=$VPC \
               --format="get(name)" 2>/dev/null || true)
    for PEERING in $PEERINGS; do
        echo "  - $PEERING (VPC: $VPC)"
        gcloud compute networks peerings delete $PEERING --network=$VPC --quiet 2>/dev/null || true
    done
done

echo ""

# =====================================================
# Étape 3 : Suppression des routes personnalisées
# =====================================================
echo "=== Suppression des routes personnalisées ==="

for ROUTE in custom-route-alpha route-alpha-to-gamma-via-beta route-gamma-to-alpha-via-beta; do
    echo "  - $ROUTE"
    gcloud compute routes delete $ROUTE --quiet 2>/dev/null || true
done

echo ""

# =====================================================
# Étape 4 : Suppression des Cloud NAT
# =====================================================
echo "=== Suppression des Cloud NAT ==="

for ROUTER in router-nat-shared; do
    NATS=$(gcloud compute routers nats list --router=$ROUTER --region=$REGION \
           --format="get(name)" 2>/dev/null || true)
    for NAT in $NATS; do
        echo "  - $NAT (Router: $ROUTER)"
        gcloud compute routers nats delete $NAT --router=$ROUTER --region=$REGION --quiet 2>/dev/null || true
    done
done

echo ""

# =====================================================
# Étape 5 : Suppression des Cloud Routers
# =====================================================
echo "=== Suppression des Cloud Routers ==="

for ROUTER in router-nat-shared; do
    echo "  - $ROUTER"
    gcloud compute routers delete $ROUTER --region=$REGION --quiet 2>/dev/null || true
done

echo ""

# =====================================================
# Étape 6 : Suppression des règles de pare-feu
# =====================================================
echo "=== Suppression des règles de pare-feu ==="

# Lister toutes les règles pour les VPC du Module 4
for VPC in vpc-alpha vpc-beta vpc-gamma shared-vpc-sim vpc-hub vpc-partner; do
    RULES=$(gcloud compute firewall-rules list --filter="network:$VPC" \
            --format="get(name)" 2>/dev/null || true)
    for RULE in $RULES; do
        echo "  - $RULE"
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
    done
done

echo ""

# =====================================================
# Étape 7 : Suppression des sous-réseaux
# =====================================================
echo "=== Suppression des sous-réseaux ==="

# Liste des sous-réseaux à supprimer
SUBNETS="subnet-alpha subnet-beta subnet-gamma subnet-frontend subnet-backend subnet-data subnet-prod subnet-staging subnet-dev subnet-partner"

for SUBNET in $SUBNETS; do
    echo "  - $SUBNET"
    gcloud compute networks subnets delete $SUBNET --region=$REGION --quiet 2>/dev/null || true
done

echo ""

# =====================================================
# Étape 8 : Suppression des VPCs
# =====================================================
echo "=== Suppression des VPCs ==="

for VPC in vpc-alpha vpc-beta vpc-gamma shared-vpc-sim vpc-hub vpc-partner; do
    echo "  - $VPC"
    gcloud compute networks delete $VPC --quiet 2>/dev/null || true
done

echo ""

# =====================================================
# Étape 9 : Nettoyage Shared VPC (si applicable)
# =====================================================
echo "=== Nettoyage des configurations Shared VPC (si applicable) ==="

# Si vous avez utilisé les labs Shared VPC réels (4.5)
if [ ! -z "$SERVICE_PROJECT_1" ] && [ ! -z "$HOST_PROJECT" ]; then
    echo "Désassociation des projets de service..."
    gcloud compute shared-vpc associated-projects remove $SERVICE_PROJECT_1 \
        --host-project=$HOST_PROJECT --quiet 2>/dev/null || true
    gcloud compute shared-vpc associated-projects remove $SERVICE_PROJECT_2 \
        --host-project=$HOST_PROJECT --quiet 2>/dev/null || true

    echo "Désactivation de Shared VPC..."
    gcloud compute shared-vpc disable $HOST_PROJECT --quiet 2>/dev/null || true
else
    echo "  Pas de configuration Shared VPC réelle détectée (ignoré)"
fi

echo ""

# =====================================================
# Vérification finale
# =====================================================
echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""

echo "VPCs restants :"
gcloud compute networks list
echo ""

echo "VMs restantes :"
gcloud compute instances list --filter="zone:$ZONE"
echo ""

echo "Règles de pare-feu restantes (Module 4) :"
gcloud compute firewall-rules list --filter="network:(vpc-alpha OR vpc-beta OR vpc-gamma OR shared-vpc-sim OR vpc-hub OR vpc-partner)" 2>/dev/null || echo "Aucune"
echo ""

echo "✓ Nettoyage du Module 4 terminé avec succès !"
