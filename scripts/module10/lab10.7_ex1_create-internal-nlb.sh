#!/bin/bash
# Lab 10.7 - Exercice 10.7.1 : Créer un Internal Passthrough Network LB
# Objectif : Créer un Network Load Balancer L4 pour une base de données

set -e

echo "=== Lab 10.7 - Exercice 1 : Créer un Internal Passthrough Network LB ==="
echo ""
echo "Cas d'usage : Load balancer pour base de données"
echo ""

# Variables
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Sous-réseau pour les backends DB
echo "Création du sous-réseau pour les bases de données..."
gcloud compute networks subnets create subnet-db \
    --network=vpc-lb-lab \
    --region=$REGION \
    --range=10.0.3.0/24

echo ""
echo "Création du template pour simuler des DB..."

# Template pour simuler des DB
gcloud compute instance-templates create db-template \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-db \
    --no-address \
    --tags=db-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y netcat-openbsd
# Simuler un service DB sur le port 5432
while true; do echo -e "HTTP/1.1 200 OK\n\nDB Server: $(hostname)" | nc -l -p 5432 -q 1; done &'

echo ""
echo "Création de l'instance group..."

# Instance group
gcloud compute instance-groups managed create ig-db \
    --template=db-template \
    --size=2 \
    --zone=$ZONE

echo ""
echo "Création de la règle de pare-feu..."

# Règle de pare-feu
gcloud compute firewall-rules create vpc-lb-lab-allow-db \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:5432 \
    --source-ranges=10.0.0.0/8 \
    --target-tags=db-server

echo ""
echo "Création du health check TCP régional..."

# Health check régional TCP
gcloud compute health-checks create tcp hc-tcp-db \
    --port=5432 \
    --region=$REGION

echo ""
echo "Création du backend service L4..."

# Backend service L4
gcloud compute backend-services create backend-db \
    --protocol=TCP \
    --health-checks=hc-tcp-db \
    --health-checks-region=$REGION \
    --load-balancing-scheme=INTERNAL \
    --region=$REGION

echo ""
echo "Ajout de l'instance group au backend..."

gcloud compute backend-services add-backend backend-db \
    --instance-group=ig-db \
    --instance-group-zone=$ZONE \
    --region=$REGION

echo ""
echo "Création de la forwarding rule..."

# Forwarding rule
gcloud compute forwarding-rules create fr-db \
    --load-balancing-scheme=INTERNAL \
    --network=vpc-lb-lab \
    --subnet=subnet-db \
    --address=10.0.3.100 \
    --backend-service=backend-db \
    --ports=5432 \
    --region=$REGION

echo ""
echo "Internal Network LB créé avec succès !"
echo ""
echo "=== Résumé ==="
echo "Internal Network LB : 10.0.3.100:5432"
echo "Type : Passthrough (Layer 4)"
echo "Backend : ig-db (2 instances simulant PostgreSQL)"
echo ""
echo "Pour tester depuis vm-client :"
echo "  nc 10.0.3.100 5432"
