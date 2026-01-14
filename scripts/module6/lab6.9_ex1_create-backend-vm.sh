#!/bin/bash
# Lab 6.9 - Exercice 6.9.1 : Créer le backend avec IP publique et privée
# Objectif : Déployer une VM avec IP publique pour le split-horizon

set -e

echo "=== Lab 6.9 - Exercice 1 : Créer le backend avec IP publique et privée ==="
echo ""

export VPC_NAME="vpc-dns-lab"
export ZONE="europe-west1-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# Créer une VM avec IP publique (pour le split-horizon)
echo "Création de la VM API avec IP publique..."
gcloud compute instances create vm-api \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-dns \
    --private-network-ip=10.0.0.50 \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx
        echo "<h1>API Server</h1><p>Hostname: $(hostname)</p>" > /var/www/html/index.html
        systemctl start nginx'
echo ""

# Règle de pare-feu pour HTTP externe
echo "Création de la règle de pare-feu pour HTTP..."
gcloud compute firewall-rules create ${VPC_NAME}-allow-http \
    --network=$VPC_NAME \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server
echo ""

# Récupérer l'IP publique
export PUBLIC_IP=$(gcloud compute instances describe vm-api \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)")

echo "VM API créée avec succès !"
echo ""
echo "IP Privée : 10.0.0.50"
echo "IP Publique : $PUBLIC_IP"
