#!/bin/bash
# Lab 4.6 - Exercice 4.6.4 : Déployer les VMs (simulant les projets de service)
# Objectif : Déployer des VMs dans chaque sous-réseau avec les tags appropriés

set -e

echo "=== Lab 4.6 - Exercice 4 : Déployer les VMs ==="
echo ""

# Variables
export VPC_SHARED="shared-vpc-sim"
export ZONE="europe-west1-b"

echo "VPC : $VPC_SHARED"
echo "Zone : $ZONE"
echo ""

# VM Frontend (simule déploiement par équipe frontend)
echo "Création de vm-frontend..."
gcloud compute instances create vm-frontend \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_SHARED \
    --subnet=subnet-frontend \
    --private-network-ip=10.100.0.10 \
    --no-address \
    --tags=frontend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y nginx curl'

echo ""

# VM Backend (simule déploiement par équipe backend)
echo "Création de vm-backend..."
gcloud compute instances create vm-backend \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_SHARED \
    --subnet=subnet-backend \
    --private-network-ip=10.100.1.10 \
    --no-address \
    --tags=backend \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y python3
        echo "from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b\"Backend OK\")
HTTPServer((\"0.0.0.0\", 8080), H).serve_forever()" > /app.py
        python3 /app.py &'

echo ""

# VM Database (simule déploiement par équipe data)
echo "Création de vm-database..."
gcloud compute instances create vm-database \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_SHARED \
    --subnet=subnet-data \
    --private-network-ip=10.100.2.10 \
    --no-address \
    --tags=database \
    --image-family=debian-11 \
    --image-project=debian-cloud

echo ""
echo "VMs créées avec succès !"
echo ""

# Afficher les VMs
echo "=== VMs déployées ==="
gcloud compute instances list --filter="zone:$ZONE AND name:(vm-frontend OR vm-backend OR vm-database)"
