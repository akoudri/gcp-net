#!/bin/bash
# Nettoyage complet des ressources du Module 3
# Objectif : Supprimer toutes les ressources créées dans les labs

set -e

echo "=== Nettoyage des ressources du Module 3 ==="
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
echo "=== Suppression des VMs ==="
# Labs 3.1, 3.2, 3.3
for VM in vm-eu vm-us vm-nat-test vm-isolated proxy-vm client1 client2 server; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null || true
done

# VMs US
gcloud compute instances delete vm-us --zone=us-central1-a --quiet 2>/dev/null || true
gcloud compute instances delete server --zone=us-central1-a --quiet 2>/dev/null || true

# Lab 3.9 - Architecture hybride
for VM in web-vm api-vm db-vm proxy-vm; do
    gcloud compute instances delete $VM --zone=europe-west1-b --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Cloud NAT ==="
# Tous les Cloud NAT créés
gcloud compute routers nats delete my-cloud-nat --router=nat-router --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers nats delete hybrid-nat --router=hybrid-router --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers nats delete nat-routes-eu --router=router-nat-routes --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers nats delete nat-appliance --router=router-nat-appliance --region=europe-west1 --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des Cloud Routers ==="
# Tous les Cloud Routers créés
gcloud compute routers delete nat-router --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers delete my-cloud-router --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers delete hybrid-router --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers delete router-nat-routes --region=europe-west1 --quiet 2>/dev/null || true
gcloud compute routers delete router-nat-appliance --region=europe-west1 --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des zones DNS ==="
# Supprimer les enregistrements puis les zones
for ZONE in internal-zone forward-zone app-internal; do
    # Annuler toute transaction en cours
    gcloud dns record-sets transaction abort --zone=$ZONE 2>/dev/null || true

    # Supprimer les enregistrements non-système (NS et SOA sont conservés automatiquement)
    RECORDS=$(gcloud dns record-sets list --zone=$ZONE --format="get(name,type)" 2>/dev/null | grep -v "NS\|SOA" || true)

    # Supprimer la zone
    gcloud dns managed-zones delete $ZONE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des politiques DNS ==="
gcloud dns policies delete inbound-dns-policy --quiet 2>/dev/null || true
gcloud dns policies delete outbound-dns-policy --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des routes personnalisées ==="
for ROUTE in route-specific route-broad route-specific-backup route-via-proxy \
             default-internet-route db-outbound-via-proxy; do
    gcloud compute routes delete $ROUTE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des règles de pare-feu ==="
# Règles du VPC routing-lab-vpc
for RULE in $(gcloud compute firewall-rules list --format="get(name)" \
              --filter="network:routing-lab-vpc" 2>/dev/null || true); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
done

# Règles du VPC hybrid-vpc
for RULE in $(gcloud compute firewall-rules list --format="get(name)" \
              --filter="network:hybrid-vpc" 2>/dev/null || true); do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des sous-réseaux ==="
# Sous-réseaux routing-lab-vpc
for SUBNET in subnet-eu subnet-us subnet-isolated; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null || true
    gcloud compute networks subnets delete $SUBNET --region=us-central1 --quiet 2>/dev/null || true
done

# Sous-réseaux hybrid-vpc
for SUBNET in subnet-frontend subnet-backend; do
    gcloud compute networks subnets delete $SUBNET --region=europe-west1 --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des VPCs ==="
gcloud compute networks delete routing-lab-vpc --quiet 2>/dev/null || true
gcloud compute networks delete hybrid-vpc --quiet 2>/dev/null || true

echo ""
echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""
echo "VPCs restants :"
gcloud compute networks list | grep -E "(routing-lab-vpc|hybrid-vpc)" || echo "  Aucun VPC des labs Module 3"
echo ""
echo "VMs restantes :"
gcloud compute instances list | grep -E "(vm-eu|vm-us|vm-nat|vm-isolated|proxy|client|server|web-vm|api-vm|db-vm)" || echo "  Aucune VM des labs Module 3"
echo ""
echo "Cloud Routers restants :"
gcloud compute routers list --regions=europe-west1,us-central1 | grep -E "(nat-router|my-cloud-router|hybrid-router|router-nat)" || echo "  Aucun Cloud Router des labs Module 3"
echo ""
echo "Zones DNS restantes :"
gcloud dns managed-zones list | grep -E "(internal-zone|forward-zone|app-internal)" || echo "  Aucune zone DNS des labs Module 3"
echo ""
