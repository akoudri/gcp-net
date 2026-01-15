#!/bin/bash
# Lab 11.2 - Exercice 11.2.1 : Créer l'infrastructure de test
# Objectif : Créer le VPC et les VMs pour tester les VPC Flow Logs

set -e

echo "=== Lab 11.2 - Exercice 1 : Créer l'infrastructure de test ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "Région : $REGION"
echo "Zone : $ZONE"
echo ""

# Créer le VPC
echo "Création du VPC vpc-observability..."
gcloud compute networks create vpc-observability \
    --subnet-mode=custom 2>/dev/null || echo "VPC vpc-observability existe déjà"

echo ""
echo "VPC créé avec succès !"
echo ""

# Créer le sous-réseau SANS Flow Logs (on les activera après)
echo "Création du sous-réseau subnet-monitored..."
gcloud compute networks subnets create subnet-monitored \
    --network=vpc-observability \
    --region=$REGION \
    --range=10.0.1.0/24 2>/dev/null || echo "Sous-réseau subnet-monitored existe déjà"

echo ""
echo "Sous-réseau créé !"
echo ""

# Règles de pare-feu
echo "Création des règles de pare-feu..."

gcloud compute firewall-rules create vpc-obs-allow-internal \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=all \
    --source-ranges=10.0.0.0/8 2>/dev/null || echo "Règle vpc-obs-allow-internal existe déjà"

gcloud compute firewall-rules create vpc-obs-allow-ssh \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 2>/dev/null || echo "Règle vpc-obs-allow-ssh existe déjà"

gcloud compute firewall-rules create vpc-obs-allow-icmp \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=icmp \
    --source-ranges=0.0.0.0/0 2>/dev/null || echo "Règle vpc-obs-allow-icmp existe déjà"

echo ""
echo "Règles de pare-feu créées !"
echo ""

# Créer deux VMs de test
echo "Création des VMs de test (vm-source et vm-dest)..."
for VM in vm-source vm-dest; do
    gcloud compute instances create $VM \
        --zone=$ZONE \
        --machine-type=e2-small \
        --network=vpc-observability \
        --subnet=subnet-monitored \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx iperf3 tcpdump
systemctl start nginx' 2>/dev/null || echo "VM $VM existe déjà"
done

echo ""
echo "VMs créées. Récupération des IPs..."
VM_SOURCE_IP=$(gcloud compute instances describe vm-source --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")
VM_DEST_IP=$(gcloud compute instances describe vm-dest --zone=$ZONE --format="get(networkInterfaces[0].networkIP)")

echo ""
echo "=== Infrastructure créée avec succès ==="
echo "vm-source: $VM_SOURCE_IP"
echo "vm-dest: $VM_DEST_IP"
echo ""
echo "Note: Les VPC Flow Logs ne sont pas encore activés. Ils seront activés dans l'exercice suivant."
