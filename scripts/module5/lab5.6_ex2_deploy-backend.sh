#!/bin/bash
# Lab 5.6 - Exercice 5.6.2 : Déployer le backend
# Objectif : Créer une VM backend avec nginx

set -e

echo "=== Lab 5.6 - Exercice 2 : Déployer le backend ==="
echo ""

export VPC_PRODUCER="vpc-producer"
export ZONE="europe-west1-b"

echo "VPC : $VPC_PRODUCER"
echo "Zone : $ZONE"
echo ""

# VM backend avec nginx
echo "Création de la VM backend avec nginx..."
gcloud compute instances create backend-vm \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_PRODUCER \
    --subnet=subnet-producer \
    --private-network-ip=10.50.0.10 \
    --no-address \
    --tags=backend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx
        echo "<h1>Service du Producteur</h1><p>Hostname: $(hostname)</p><p>IP: $(hostname -I)</p>" > /var/www/html/index.html
        systemctl enable nginx
        systemctl start nginx'

echo ""
echo "VM backend créée ! Attendre 30 secondes pour le démarrage de nginx..."
sleep 30

# Créer un Instance Group (nécessaire pour le LB)
echo ""
echo "Création de l'instance group..."
gcloud compute instance-groups unmanaged create backend-group \
    --zone=$ZONE

gcloud compute instance-groups unmanaged add-instances backend-group \
    --zone=$ZONE \
    --instances=backend-vm

# Définir le port nommé
echo "Configuration du port nommé..."
gcloud compute instance-groups unmanaged set-named-ports backend-group \
    --zone=$ZONE \
    --named-ports=http:80

echo ""
echo "=== Backend déployé ! ==="
echo ""
echo "VM : backend-vm (10.50.0.10)"
echo "Instance Group : backend-group"
echo "Service : nginx sur port 80"
