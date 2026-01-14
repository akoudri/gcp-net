#!/bin/bash
# Lab 7.10 : Scénario intégrateur - Architecture hybride multi-sites
# Objectif : Déployer une architecture hybride complète avec VPN et Cloud NAT

set -e

export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "=========================================="
echo "  DÉPLOIEMENT ARCHITECTURE HYBRIDE"
echo "=========================================="
echo ""
echo "Projet : $PROJECT_ID"
echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# ===== 1. VPC PRODUCTION GCP =====
echo ">>> Création VPC Production..."
gcloud compute networks create vpc-production \
    --subnet-mode=custom

gcloud compute networks subnets create subnet-apps \
    --network=vpc-production \
    --region=$REGION \
    --range=10.0.1.0/24

gcloud compute networks subnets create subnet-data \
    --network=vpc-production \
    --region=$REGION \
    --range=10.0.2.0/24

echo ""

# ===== 2. VPCs SITES (simulés) =====
echo ">>> Création VPCs sites..."
declare -A SITES=(
    ["paris"]="192.168.1.0/24:65002"
    ["lyon"]="192.168.2.0/24:65003"
    ["berlin"]="192.168.3.0/24:65004"
)

for SITE in "${!SITES[@]}"; do
    IFS=':' read -r RANGE ASN <<< "${SITES[$SITE]}"

    echo "  - Site $SITE ($RANGE, ASN: $ASN)"
    gcloud compute networks create vpc-site-${SITE} --subnet-mode=custom

    gcloud compute networks subnets create subnet-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --range=$RANGE
done

echo ""

# ===== 3. RÈGLES PARE-FEU =====
echo ">>> Configuration pare-feu..."
for VPC in vpc-production vpc-site-paris vpc-site-lyon vpc-site-berlin; do
    echo "  - Règles pour $VPC"
    gcloud compute firewall-rules create ${VPC}-allow-internal \
        --network=$VPC \
        --allow=tcp,udp,icmp \
        --source-ranges=10.0.0.0/8,192.168.0.0/16

    gcloud compute firewall-rules create ${VPC}-allow-ssh \
        --network=$VPC \
        --allow=tcp:22 \
        --source-ranges=35.235.240.0/20
done

echo ""

# ===== 4. CLOUD ROUTER PRODUCTION =====
echo ">>> Création Cloud Router Production..."
gcloud compute routers create router-prod \
    --network=vpc-production \
    --region=$REGION \
    --asn=65001

echo ""

# ===== 5. HA VPN GATEWAY PRODUCTION =====
echo ">>> Création HA VPN Gateway Production..."
gcloud compute vpn-gateways create vpn-gw-prod \
    --network=vpc-production \
    --region=$REGION

echo ""

# ===== 6. CLOUD NAT POUR LE VPC PRODUCTION =====
echo ">>> Configuration Cloud NAT Production..."
gcloud compute routers nats create nat-hybrid-prod \
    --router=router-prod \
    --region=$REGION \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

echo ""

# ===== 7. CONFIGURATION PAR SITE =====
echo ">>> Configuration VPN par site..."
for SITE in "${!SITES[@]}"; do
    IFS=':' read -r RANGE ASN <<< "${SITES[$SITE]}"

    echo "  - Configuration site: $SITE (ASN: $ASN)"

    # Cloud Router du site
    gcloud compute routers create router-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION \
        --asn=$ASN

    # Cloud NAT pour le site
    gcloud compute routers nats create nat-hybrid-${SITE} \
        --router=router-${SITE} \
        --region=$REGION \
        --nat-all-subnet-ip-ranges \
        --auto-allocate-nat-external-ips

    # VPN Gateway du site
    gcloud compute vpn-gateways create vpn-gw-${SITE} \
        --network=vpc-site-${SITE} \
        --region=$REGION

    # Secrets
    SECRET=$(openssl rand -base64 24)

    # Tunnels Prod → Site
    gcloud compute vpn-tunnels create tunnel-prod-to-${SITE} \
        --vpn-gateway=vpn-gw-prod \
        --vpn-gateway-region=$REGION \
        --peer-gcp-gateway=vpn-gw-${SITE} \
        --peer-gcp-gateway-region=$REGION \
        --interface=0 \
        --ike-version=2 \
        --shared-secret="$SECRET" \
        --router=router-prod \
        --router-region=$REGION

    # Tunnels Site → Prod
    gcloud compute vpn-tunnels create tunnel-${SITE}-to-prod \
        --vpn-gateway=vpn-gw-${SITE} \
        --vpn-gateway-region=$REGION \
        --peer-gcp-gateway=vpn-gw-prod \
        --peer-gcp-gateway-region=$REGION \
        --interface=0 \
        --ike-version=2 \
        --shared-secret="$SECRET" \
        --router=router-${SITE} \
        --router-region=$REGION
done

echo ""

# ===== 8. CONFIGURATION BGP =====
echo ">>> Configuration BGP..."
INDEX=0
for SITE in "${!SITES[@]}"; do
    IFS=':' read -r RANGE ASN <<< "${SITES[$SITE]}"

    IP_PROD="169.254.${INDEX}.1"
    IP_SITE="169.254.${INDEX}.2"

    echo "  - BGP site $SITE"

    # Interface BGP côté Prod
    gcloud compute routers add-interface router-prod \
        --interface-name=bgp-if-${SITE} \
        --vpn-tunnel=tunnel-prod-to-${SITE} \
        --ip-address=$IP_PROD \
        --mask-length=30 \
        --region=$REGION

    # Interface BGP côté Site
    gcloud compute routers add-interface router-${SITE} \
        --interface-name=bgp-if-prod \
        --vpn-tunnel=tunnel-${SITE}-to-prod \
        --ip-address=$IP_SITE \
        --mask-length=30 \
        --region=$REGION

    # Peer BGP côté Prod
    gcloud compute routers add-bgp-peer router-prod \
        --peer-name=peer-${SITE} \
        --peer-asn=$ASN \
        --interface=bgp-if-${SITE} \
        --peer-ip-address=$IP_SITE \
        --region=$REGION

    # Peer BGP côté Site
    gcloud compute routers add-bgp-peer router-${SITE} \
        --peer-name=peer-prod \
        --peer-asn=65001 \
        --interface=bgp-if-prod \
        --peer-ip-address=$IP_PROD \
        --region=$REGION

    ((INDEX++))
done

echo ""

# ===== 9. VMs DE TEST =====
echo ">>> Déploiement VMs de test..."
gcloud compute instances create vm-prod \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=vpc-production \
    --subnet=subnet-apps \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsutils traceroute mtr'

for SITE in paris lyon berlin; do
    gcloud compute instances create vm-${SITE} \
        --zone=$ZONE \
        --machine-type=e2-micro \
        --network=vpc-site-${SITE} \
        --subnet=subnet-${SITE} \
        --no-address \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata=startup-script='#!/bin/bash
            apt-get update && apt-get install -y dnsutils traceroute mtr'
done

echo ""
echo "=========================================="
echo "  DÉPLOIEMENT TERMINÉ"
echo "=========================================="
echo ""
echo "Vérification des tunnels:"
gcloud compute vpn-tunnels list --filter="region:$REGION" \
    --format="table(name,status)"
echo ""
echo "Vérification BGP:"
gcloud compute routers get-status router-prod --region=$REGION \
    --format="table(result.bgpPeerStatus[].name,result.bgpPeerStatus[].status)"
echo ""
echo "Vérification Cloud NAT:"
gcloud compute routers nats list --router=router-prod --region=$REGION
for SITE in paris lyon berlin; do
    gcloud compute routers nats list --router=router-${SITE} --region=$REGION
done

echo ""
echo "Questions de validation :"
echo "1. Comment Cloud NAT facilite-t-il la gestion d'une architecture hybride multi-sites ?"
echo "2. Quel est l'impact de Cloud NAT sur le routage BGP dans cette architecture ?"
echo "3. Comment tester que chaque site peut accéder à Internet via Cloud NAT tout en communiquant entre eux via VPN ?"
