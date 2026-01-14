#!/bin/bash
# Nettoyage complet des ressources du Module 10
# Objectif : Supprimer toutes les ressources créées dans les labs de Load Balancing

set -e

echo "=== Nettoyage des ressources du Module 10 ==="
echo ""
echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources créées."
echo ""
read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo ""
echo "=== Suppression des Forwarding Rules ==="
gcloud compute forwarding-rules delete fr-http-app --global --quiet 2>/dev/null || true
gcloud compute forwarding-rules delete fr-internal --region=$REGION --quiet 2>/dev/null || true
gcloud compute forwarding-rules delete fr-db --region=$REGION --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des Target Proxies ==="
gcloud compute target-http-proxies delete proxy-http-app --quiet 2>/dev/null || true
gcloud compute target-http-proxies delete proxy-internal --region=$REGION --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des URL Maps ==="
for URLMAP in urlmap-app urlmap-multihost urlmap-paths urlmap-canary urlmap-header-routing urlmap-internal urlmap-hybrid urlmap-advanced; do
    gcloud compute url-maps delete $URLMAP --global --quiet 2>/dev/null || true
    gcloud compute url-maps delete $URLMAP --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Backend Services (Global) ==="
for BACKEND in backend-web backend-api backend-v1 backend-v2 backend-hybrid backend-cloudrun backend-external; do
    gcloud compute backend-services delete $BACKEND --global --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Backend Services (Regional) ==="
for BACKEND in backend-users backend-orders backend-default backend-db; do
    gcloud compute backend-services delete $BACKEND --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Backend Buckets ==="
gcloud compute backend-buckets delete bucket-static --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des Health Checks (Global) ==="
for HC in hc-web hc-api; do
    gcloud compute health-checks delete $HC --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Health Checks (Regional) ==="
for HC in hc-internal hc-tcp-db; do
    gcloud compute health-checks delete $HC --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des NEGs ==="
gcloud compute network-endpoint-groups delete neg-onprem --zone=$ZONE --quiet 2>/dev/null || true
gcloud compute network-endpoint-groups delete neg-cloudrun --region=$REGION --quiet 2>/dev/null || true
gcloud compute network-endpoint-groups delete neg-external --global --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des Instance Groups ==="
for IG in ig-web ig-api ig-v1 ig-v2 ig-users ig-orders ig-default ig-db; do
    gcloud compute instance-groups managed delete $IG --zone=$ZONE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Instance Templates ==="
for TEMPLATE in web-template api-template web-template-v1 web-template-v2 users-template orders-template default-template db-template; do
    gcloud compute instance-templates delete $TEMPLATE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des VMs ==="
gcloud compute instances delete vm-client --zone=$ZONE --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des IP addresses ==="
gcloud compute addresses delete lb-ip-global --global --quiet 2>/dev/null || true

echo ""
echo "=== Suppression du bucket ==="
gsutil rm -r gs://${PROJECT_ID}-static-content 2>/dev/null || true

echo ""
echo "=== Suppression des Cloud Run services ==="
gcloud run services delete hello-service --region=$REGION --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des règles de pare-feu ==="
for RULE in vpc-lb-lab-allow-health-check vpc-lb-lab-allow-iap vpc-lb-lab-allow-internal-lb vpc-lb-lab-allow-db; do
    gcloud compute firewall-rules delete $RULE --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression des Cloud NAT ==="
gcloud compute routers nats delete nat-internal-lb --router=router-nat-lb --region=$REGION --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des Cloud Routers ==="
gcloud compute routers delete router-nat-lb --region=$REGION --quiet 2>/dev/null || true

echo ""
echo "=== Suppression des sous-réseaux ==="
for SUBNET in subnet-web subnet-internal subnet-db subnet-proxy-only; do
    gcloud compute networks subnets delete $SUBNET --region=$REGION --quiet 2>/dev/null || true
done

echo ""
echo "=== Suppression du VPC ==="
gcloud compute networks delete vpc-lb-lab --quiet 2>/dev/null || true

echo ""
echo "=== Nettoyage des fichiers locaux ==="
rm -f cookies.txt urlmap-export.yaml urlmap-advanced.yaml urlmap-canary.yaml urlmap-header-routing.yaml urlmap-hybrid.yaml 2>/dev/null || true
rm -f cdn-signing-key.txt cdn-signing-key-v2.txt generate_signed_url.py 2>/dev/null || true

echo ""
echo "=== Nettoyage terminé ==="
echo ""
echo "Vérification des ressources restantes :"
echo ""
echo "VPCs restants :"
gcloud compute networks list --filter="name:vpc-lb-lab"
echo ""
echo "VMs restantes :"
gcloud compute instances list --filter="name~(ig-.*|vm-client)"
echo ""
echo "Backend Services restants :"
gcloud compute backend-services list --filter="name~(backend-.*)"
echo ""

if [ $(gcloud compute networks list --filter="name:vpc-lb-lab" --format="value(name)" | wc -l) -eq 0 ]; then
    echo "✓ Toutes les ressources du Module 10 ont été supprimées avec succès !"
else
    echo "⚠️  Certaines ressources n'ont pas pu être supprimées. Vérifiez manuellement."
fi
