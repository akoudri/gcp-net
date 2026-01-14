#!/bin/bash
# Lab 6.11 - Scénario intégrateur : Architecture DNS hybride
# Objectif : Déployer une architecture DNS complète

set -e

echo "=== Lab 6.11 : Scénario intégrateur - Architecture DNS hybride ==="
echo ""

export PROJECT_ID=$(gcloud config get-value project)
export VPC_PROD="vpc-prod-dns"
export REGION="europe-west1"
export ZONE="${REGION}-b"
export DOMAIN="example-corp.com"

echo "Projet : $PROJECT_ID"
echo "VPC : $VPC_PROD"
echo "Région : $REGION"
echo "Domaine : $DOMAIN"
echo ""

echo "=== 1. Création du VPC Production ==="
gcloud compute networks create $VPC_PROD \
    --subnet-mode=custom \
    --description="VPC Production avec DNS hybride"

gcloud compute networks subnets create subnet-prod \
    --network=$VPC_PROD \
    --region=$REGION \
    --range=10.1.0.0/24

gcloud compute networks subnets create subnet-onprem-sim \
    --network=$VPC_PROD \
    --region=$REGION \
    --range=192.168.1.0/24
echo ""

# Pare-feu
echo "Configuration des règles de pare-feu..."
gcloud compute firewall-rules create ${VPC_PROD}-allow-all-internal \
    --network=$VPC_PROD \
    --allow=tcp,udp,icmp \
    --source-ranges=10.0.0.0/8,192.168.0.0/16

gcloud compute firewall-rules create ${VPC_PROD}-allow-ssh-iap \
    --network=$VPC_PROD \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20

gcloud compute firewall-rules create ${VPC_PROD}-allow-http \
    --network=$VPC_PROD \
    --allow=tcp:80,tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server
echo ""

echo "=== 2. Déploiement des VMs ==="
# VM API
echo "Création de VM API..."
gcloud compute instances create vm-api-prod \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_PROD \
    --subnet=subnet-prod \
    --private-network-ip=10.1.0.10 \
    --tags=http-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx dnsutils
        echo "<h1>API Production</h1>" > /var/www/html/index.html'

# VM DB
echo "Création de VM DB..."
gcloud compute instances create vm-db-prod \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_PROD \
    --subnet=subnet-prod \
    --private-network-ip=10.1.0.20 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# VM Cache
echo "Création de VM Cache..."
gcloud compute instances create vm-cache-prod \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_PROD \
    --subnet=subnet-prod \
    --private-network-ip=10.1.0.30 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

# DNS Server on-premise simulé
echo "Création du serveur DNS on-premise..."
gcloud compute instances create dns-onprem \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_PROD \
    --subnet=subnet-onprem-sim \
    --private-network-ip=192.168.1.53 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y dnsmasq
        cat > /etc/dnsmasq.conf << EOF
listen-address=0.0.0.0
bind-interfaces
no-resolv
server=8.8.8.8
address=/server.corp.local/192.168.1.100
address=/ldap.corp.local/192.168.1.101
log-queries
EOF
        systemctl restart dnsmasq'
echo ""

echo "Attente de 30 secondes pour que les VMs démarrent..."
sleep 30
echo ""

echo "=== 3. Configuration des zones DNS ==="

# Zone privée prod.internal
echo "Création de la zone privée prod.internal..."
gcloud dns managed-zones create zone-prod-internal \
    --dns-name="prod.internal." \
    --description="Zone privée production" \
    --visibility=private \
    --networks=$VPC_PROD

gcloud dns record-sets create "api.prod.internal." \
    --zone=zone-prod-internal --type=A --ttl=300 --rrdatas="10.1.0.10"

gcloud dns record-sets create "db.prod.internal." \
    --zone=zone-prod-internal --type=A --ttl=300 --rrdatas="10.1.0.20"

gcloud dns record-sets create "cache.prod.internal." \
    --zone=zone-prod-internal --type=A --ttl=300 --rrdatas="10.1.0.30"
echo ""

# Zone publique
echo "Création de la zone publique..."
gcloud dns managed-zones create zone-corp-public \
    --dns-name="${DOMAIN}." \
    --description="Zone publique corporate" \
    --visibility=public

PUBLIC_IP=$(gcloud compute instances describe vm-api-prod \
    --zone=$ZONE --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

gcloud dns record-sets create "api.${DOMAIN}." \
    --zone=zone-corp-public --type=A --ttl=300 --rrdatas="$PUBLIC_IP"
echo ""

# Zone privée pour split-horizon
echo "Création de la zone privée pour split-horizon..."
gcloud dns managed-zones create zone-corp-private \
    --dns-name="${DOMAIN}." \
    --description="Zone privée split-horizon" \
    --visibility=private \
    --networks=$VPC_PROD

gcloud dns record-sets create "api.${DOMAIN}." \
    --zone=zone-corp-private --type=A --ttl=300 --rrdatas="10.1.0.10"
echo ""

# Zone de forwarding vers on-premise
echo "Création de la zone de forwarding..."
gcloud dns managed-zones create zone-forward-corp \
    --dns-name="corp.local." \
    --description="Forwarding vers DNS on-premise" \
    --visibility=private \
    --networks=$VPC_PROD \
    --forwarding-targets="192.168.1.53"
echo ""

echo "=== 4. Politique DNS avec logging et inbound ==="
gcloud dns policies create policy-prod \
    --networks=$VPC_PROD \
    --enable-inbound-forwarding \
    --enable-logging \
    --description="Politique DNS production"
echo ""

echo "=== 5. Récupération des informations ==="
echo ""
echo "=== ARCHITECTURE DNS DÉPLOYÉE ==="
echo ""
echo "VPC: $VPC_PROD"
echo "Domaine public: $DOMAIN"
echo "IP publique API: $PUBLIC_IP"
echo ""

echo "Zones DNS:"
gcloud dns managed-zones list --format="table(name,dnsName,visibility)"
echo ""

echo "Inbound forwarder:"
gcloud compute addresses list --filter="purpose=DNS_RESOLVER"
echo ""

echo "=== Déploiement terminé ==="
echo ""
echo "Tests disponibles :"
echo "1. Test zone privée : gcloud compute ssh vm-api-prod --zone=$ZONE --command='nslookup db.prod.internal'"
echo "2. Test split-horizon : gcloud compute ssh vm-api-prod --zone=$ZONE --command='nslookup api.${DOMAIN}'"
echo "3. Test forwarding : gcloud compute ssh vm-api-prod --zone=$ZONE --command='nslookup server.corp.local'"
