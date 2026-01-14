#!/bin/bash
# Lab 3.3 - Exercice 3.3.2 : Déployer l'infrastructure
# Objectif : Créer les VMs pour le routage via appliance

set -e

echo "=== Lab 3.3 - Exercice 2 : Déployer l'infrastructure ==="
echo ""

# Variables
export VPC_NAME="routing-lab-vpc"
export REGION_EU="europe-west1"
export REGION_US="us-central1"

echo "Déploiement de proxy-vm (appliance)..."
# VM Proxy/Appliance avec IP forwarding
gcloud compute instances create proxy-vm \
    --zone=${REGION_EU}-b \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.100 \
    --no-address \
    --can-ip-forward \
    --tags=proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        apt-get update && apt-get install -y tcpdump iptables
        # Activer le forwarding avec iptables
        iptables -A FORWARD -i ens4 -j ACCEPT
        iptables -A FORWARD -o ens4 -j ACCEPT'

echo ""
echo "Déploiement de client1 (avec tag needs-proxy)..."
# Client 1 - avec tag "needs-proxy"
gcloud compute instances create client1 \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.20 \
    --no-address \
    --tags=needs-proxy \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "Déploiement de client2 (sans tag)..."
# Client 2 - sans tag
gcloud compute instances create client2 \
    --zone=${REGION_EU}-b \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-eu \
    --private-network-ip=10.1.0.21 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "Déploiement de server (destination)..."
# Serveur de destination
gcloud compute instances create server \
    --zone=${REGION_US}-a \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-us \
    --private-network-ip=10.2.0.50 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx tcpdump
        echo "Server OK - $(hostname)" > /var/www/html/index.html'

echo ""
echo "Infrastructure déployée avec succès !"
echo ""

echo "=== VMs créées ==="
gcloud compute instances list --filter="name:(proxy-vm OR client1 OR client2 OR server)"
echo ""
