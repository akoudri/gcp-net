#!/bin/bash
# Lab 9.2 - Exercice 9.2.2 : Créer le template d'instance et le groupe
# Objectif : Créer un template et un groupe d'instances managé avec serveur web

set -e

echo "=== Lab 9.2 - Exercice 2 : Créer le template d'instance et le groupe ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "Zone : $ZONE"
echo ""

# Template d'instance avec serveur web
echo "Création du template d'instance web-template..."
gcloud compute instance-templates create web-template \
    --machine-type=e2-small \
    --network=vpc-armor-lab \
    --subnet=subnet-web \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx

# Page personnalisée avec infos
cat > /var/www/html/index.html << HTMLEOF
<!DOCTYPE html>
<html>
<head><title>Cloud Armor Lab</title></head>
<body>
<h1>Cloud Armor Lab</h1>
<p>Hostname: $(hostname)</p>
<p>Zone: '"${ZONE}"'</p>
<p>Internal IP: $(hostname -I | awk "{print \$1}")</p>
<p>Date: $(date)</p>
</body>
</html>
HTMLEOF

# Endpoint de health check
mkdir -p /var/www/html/health
echo "OK" > /var/www/html/health/index.html

systemctl restart nginx'

echo ""
echo "Création du groupe d'instances managé web-ig..."
gcloud compute instance-groups managed create web-ig \
    --template=web-template \
    --size=2 \
    --zone=$ZONE

echo ""
echo "Configuration de l'autoscaling..."
gcloud compute instance-groups managed set-autoscaling web-ig \
    --zone=$ZONE \
    --min-num-replicas=2 \
    --max-num-replicas=5 \
    --target-cpu-utilization=0.7

echo ""
echo "Configuration du named port..."
gcloud compute instance-groups managed set-named-ports web-ig \
    --zone=$ZONE \
    --named-ports=http:80

echo ""
echo "Template et groupe d'instances créés avec succès !"
echo ""

# Vérifier
echo "=== Template d'instance ==="
gcloud compute instance-templates describe web-template
echo ""

echo "=== Groupe d'instances ==="
gcloud compute instance-groups managed describe web-ig --zone=$ZONE
echo ""

echo "Attente de la création des instances (cela peut prendre quelques minutes)..."
echo "Vous pouvez vérifier l'état avec : gcloud compute instance-groups managed list-instances web-ig --zone=$ZONE"
