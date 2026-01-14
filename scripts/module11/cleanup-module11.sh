#!/bin/bash
# Nettoyage complet des ressources du Module 11
# Objectif : Supprimer toutes les ressources créées dans les labs

set -e

echo "=== Nettoyage des ressources du Module 11 ==="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo ""
echo "=== Suppression Packet Mirroring ==="
gcloud compute packet-mirrorings delete mirror-policy-prod --region=$REGION --quiet 2>/dev/null || true
gcloud compute forwarding-rules delete collector-ilb --region=$REGION --quiet 2>/dev/null || true
gcloud compute backend-services delete collector-backend --region=$REGION --quiet 2>/dev/null || true
gcloud compute health-checks delete hc-collector --region=$REGION --quiet 2>/dev/null || true
gcloud compute instance-groups unmanaged delete ig-collector --zone=$ZONE --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des VMs ==="
for VM in vm-source vm-dest vm-collector; do
    gcloud compute instances delete $VM --zone=$ZONE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression Connectivity Tests ==="
gcloud network-management connectivity-tests delete test-source-to-dest --quiet 2>/dev/null || true
gcloud network-management connectivity-tests delete test-to-internet --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des sinks de logs ==="
gcloud logging sinks delete flow-logs-to-bq --quiet 2>/dev/null || true
gcloud logging sinks delete archive-old-logs --quiet 2>/dev/null || true

echo ""
echo "=== Suppression BigQuery dataset ==="
bq rm -r -f ${PROJECT_ID}:network_logs 2>/dev/null || true

echo ""
echo "=== Suppression du bucket Cloud Storage ==="
gsutil rm -r gs://${PROJECT_ID}-logs-archive 2>/dev/null || true

echo ""
echo "=== Suppression des dashboards ==="
for DASHBOARD in $(gcloud monitoring dashboards list --format="get(name)" 2>/dev/null); do
    gcloud monitoring dashboards delete $DASHBOARD --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des alerting policies ==="
for POLICY in $(gcloud alpha monitoring policies list --format="get(name)" 2>/dev/null); do
    gcloud alpha monitoring policies delete $POLICY --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des notification channels ==="
for CHANNEL in $(gcloud alpha monitoring channels list --format="get(name)" 2>/dev/null); do
    gcloud alpha monitoring channels delete $CHANNEL --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des règles de pare-feu ==="
for RULE in $(gcloud compute firewall-rules list --filter="network:vpc-observability" --format="get(name)" 2>/dev/null); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-monitored subnet-collector; do
    gcloud compute networks subnets delete $SUBNET --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression du VPC ==="
gcloud compute networks delete vpc-observability --quiet 2>/dev/null || true

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
echo "Dashboards restants :"
gcloud monitoring dashboards list 2>/dev/null || echo "Aucun dashboard"
echo ""
echo "Alerting policies restantes :"
gcloud alpha monitoring policies list 2>/dev/null || echo "Aucune politique"
