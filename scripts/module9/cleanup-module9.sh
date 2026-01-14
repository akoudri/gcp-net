#!/bin/bash
# Nettoyage complet des ressources du Module 9
# Objectif : Supprimer toutes les ressources créées dans les labs

set -e

echo "=== Nettoyage des ressources du Module 9 ==="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

REGION="europe-west1"
ZONE="${REGION}-b"

echo ""
echo "=== Suppression des politiques Cloud Armor ==="
for POLICY in policy-web-app policy-complete edge-policy; do
    echo "Traitement de la politique: $POLICY"

    # Détacher des backends
    for BACKEND in $(gcloud compute backend-services list --format="get(name)" 2>/dev/null); do
        gcloud compute backend-services update $BACKEND \
            --security-policy="" --global 2>/dev/null || true
        gcloud compute backend-services update $BACKEND \
            --edge-security-policy="" --global 2>/dev/null || true
    done

    # Supprimer la politique
    gcloud compute security-policies delete $POLICY --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression du Load Balancer ==="
gcloud compute forwarding-rules delete fr-http --global --quiet 2>/dev/null || true
gcloud compute target-http-proxies delete proxy-http --quiet 2>/dev/null || true
gcloud compute url-maps delete urlmap-web --quiet 2>/dev/null || true
gcloud compute backend-services delete backend-web --global --quiet 2>/dev/null || true
gcloud compute health-checks delete hc-http-80 --quiet 2>/dev/null || true
gcloud compute addresses delete lb-ip --global --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des instances ==="
gcloud compute instance-groups managed delete web-ig --zone=$ZONE --quiet 2>/dev/null || true
gcloud compute instance-templates delete web-template --quiet 2>/dev/null || true

echo ""
echo "=== Suppression du réseau ==="
gcloud compute firewall-rules delete vpc-armor-lab-allow-health-check --quiet 2>/dev/null || true
gcloud compute firewall-rules delete vpc-armor-lab-allow-lb --quiet 2>/dev/null || true
gcloud compute firewall-rules delete vpc-armor-lab-allow-iap --quiet 2>/dev/null || true
gcloud compute networks subnets delete subnet-web --region=$REGION --quiet 2>/dev/null || true
gcloud compute networks delete vpc-armor-lab --quiet 2>/dev/null || true

echo ""
echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""

echo "Politiques Cloud Armor restantes :"
gcloud compute security-policies list 2>/dev/null || echo "Aucune"
echo ""

echo "Load Balancers restants :"
gcloud compute forwarding-rules list --global 2>/dev/null || echo "Aucun"
echo ""

echo "VPCs restants (vpc-armor-lab devrait être supprimé) :"
gcloud compute networks list | grep vpc-armor-lab || echo "vpc-armor-lab supprimé avec succès"
echo ""

echo "Groupes d'instances restants :"
gcloud compute instance-groups managed list 2>/dev/null || echo "Aucun"
