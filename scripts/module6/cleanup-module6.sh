#!/bin/bash
# Nettoyage complet des ressources du Module 6
# Objectif : Supprimer toutes les ressources créées dans les labs Cloud DNS

set -e

echo "=== Nettoyage des ressources du Module 6 - Cloud DNS ==="
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
echo "Démarrage du nettoyage..."
echo ""

# Variables
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=== Suppression des VMs ==="
for VM in vm1 vm2 db vm-api dns-server client-onprem vm-spoke vm-api-prod vm-db-prod vm-cache-prod dns-onprem; do
    echo "Suppression de $VM..."
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || echo "  $VM non trouvée"
done
echo ""

echo "=== Suppression des politiques DNS ==="
for POLICY in policy-inbound policy-dns-full policy-prod; do
    echo "Suppression de $POLICY..."
    gcloud dns policies delete $POLICY --quiet 2>/dev/null || echo "  $POLICY non trouvée"
done
echo ""

echo "=== Suppression des zones DNS ==="
for DNS_ZONE in zone-lab-internal zone-public-lab zone-forward-corp zone-services \
            peering-to-hub zone-split-public zone-split-private zone-prod-internal \
            zone-corp-public zone-corp-private; do
    echo "Suppression des enregistrements de $DNS_ZONE..."
    # Supprimer les enregistrements (sauf SOA et NS)
    RECORDS=$(gcloud dns record-sets list --zone=$DNS_ZONE \
                --format="csv[no-heading](name,type)" 2>/dev/null | grep -v "SOA\|NS" || true)
    while IFS=',' read -r NAME TYPE; do
        if [ -n "$NAME" ] && [ -n "$TYPE" ]; then
            echo "  Suppression de $NAME ($TYPE)..."
            gcloud dns record-sets delete "$NAME" --zone=$DNS_ZONE --type=$TYPE --quiet 2>/dev/null || true
        fi
    done <<< "$RECORDS"

    echo "Suppression de la zone $DNS_ZONE..."
    gcloud dns managed-zones delete $DNS_ZONE --quiet 2>/dev/null || echo "  $DNS_ZONE non trouvée"
done
echo ""

echo "=== Suppression des métriques de logging ==="
gcloud logging metrics delete dns-nxdomain-count --quiet 2>/dev/null || echo "  Métrique non trouvée"
echo ""

echo "=== Suppression des health checks ==="
gcloud compute health-checks delete hc-dns-wrr --quiet 2>/dev/null || echo "  Health check non trouvé"
gcloud compute health-checks delete hc-dns-geo --quiet 2>/dev/null || echo "  Health check non trouvé"
echo ""

echo "=== Suppression des NAT Gateways ==="
for ROUTER in router-nat-dns router-nat-spoke; do
    for REGION_ITEM in $REGION; do
        echo "Suppression des NAT configs du router $ROUTER..."
        NATS=$(gcloud compute routers nats list --router=$ROUTER --region=$REGION_ITEM --format="get(name)" 2>/dev/null || true)
        for NAT in $NATS; do
            echo "  Suppression de $NAT..."
            gcloud compute routers nats delete $NAT --router=$ROUTER --region=$REGION_ITEM --quiet 2>/dev/null || true
        done
    done
done
echo ""

echo "=== Suppression des Cloud Routers ==="
for ROUTER in router-nat-dns router-nat-spoke; do
    for REGION_ITEM in $REGION; do
        echo "Suppression du router $ROUTER..."
        gcloud compute routers delete $ROUTER --region=$REGION_ITEM --quiet 2>/dev/null || echo "  $ROUTER non trouvé"
    done
done
echo ""

echo "=== Suppression des règles de pare-feu ==="
for VPC in vpc-dns-lab vpc-hub vpc-spoke vpc-prod-dns; do
    echo "Suppression des règles de pare-feu pour $VPC..."
    RULES=$(gcloud compute firewall-rules list \
                  --filter="network:$VPC" --format="get(name)" 2>/dev/null || true)
    for RULE in $RULES; do
        echo "  Suppression de $RULE..."
        gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
    done
done
echo ""

echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-dns subnet-onprem subnet-hub subnet-spoke subnet-prod subnet-onprem-sim; do
    echo "Suppression de $SUBNET..."
    gcloud compute networks subnets delete $SUBNET \
        --region=$REGION --quiet 2>/dev/null || echo "  $SUBNET non trouvé"
done
echo ""

echo "=== Suppression des VPCs ==="
for VPC in vpc-dns-lab vpc-hub vpc-spoke vpc-prod-dns; do
    echo "Suppression de $VPC..."
    gcloud compute networks delete $VPC --quiet 2>/dev/null || echo "  $VPC non trouvé"
done
echo ""

echo "=== Suppression des fichiers temporaires ==="
rm -f zone-public-lab.zone /tmp/test_wrr.sh 2>/dev/null || true
echo ""

echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""

echo "VPCs restants :"
gcloud compute networks list --format="table(name,autoCreateSubnetworks)"
echo ""

echo "VMs restantes :"
gcloud compute instances list --format="table(name,zone,status)"
echo ""

echo "Zones DNS restantes :"
gcloud dns managed-zones list --format="table(name,dnsName,visibility)"
echo ""

echo "Si des ressources persistent, vous pouvez les supprimer manuellement."
echo "Utilisez la console GCP ou les commandes gcloud pour vérifier et nettoyer."
