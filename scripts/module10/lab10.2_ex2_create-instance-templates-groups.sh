#!/bin/bash
# Lab 10.2 - Exercice 10.2.2 : Créer les Instance Templates et Groups
# Objectif : Créer les templates et groupes d'instances pour le frontend et l'API

set -e

echo "=== Lab 10.2 - Exercice 2 : Créer les Instance Templates et Groups ==="
echo ""

# Variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Projet : $PROJECT_ID"
echo "Zone : $ZONE"
echo ""

# Template pour le frontend web
echo "Création du template web-template..."
gcloud compute instance-templates create web-template \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --region=$REGION \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
HOSTNAME=$(hostname)
ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>Web Server</title></head>
<body>
<h1>Frontend Web Server</h1>
<p>Hostname: $HOSTNAME</p>
<p>Zone: $ZONE</p>
<p>Version: v1</p>
</body>
</html>
EOF
mkdir -p /var/www/html/health
echo "OK" > /var/www/html/health/index.html
systemctl restart nginx' 2>/dev/null || echo "Template web-template existe déjà"

echo ""
echo "Création du template api-template..."

# Template pour l'API
gcloud compute instance-templates create api-template \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --region=$REGION \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
HOSTNAME=$(hostname)
cat > /var/www/html/index.html << EOF
{"service": "api", "hostname": "$HOSTNAME", "version": "v1"}
EOF
mkdir -p /var/www/html/health /var/www/html/api
echo "OK" > /var/www/html/health/index.html
echo "{\"status\": \"ok\", \"service\": \"api\"}" > /var/www/html/api/index.html
systemctl restart nginx' 2>/dev/null || echo "Template api-template existe déjà"

echo ""
echo "Création des Managed Instance Groups..."

# Créer les Managed Instance Groups
gcloud compute instance-groups managed create ig-web \
    --template=web-template \
    --size=2 \
    --zone=$ZONE 2>/dev/null || echo "Instance group ig-web existe déjà"

gcloud compute instance-groups managed create ig-api \
    --template=api-template \
    --size=2 \
    --zone=$ZONE 2>/dev/null || echo "Instance group ig-api existe déjà"

echo ""
echo "Configuration des named ports..."

# Configurer les named ports
gcloud compute instance-groups managed set-named-ports ig-web \
    --zone=$ZONE \
    --named-ports=http:80

gcloud compute instance-groups managed set-named-ports ig-api \
    --zone=$ZONE \
    --named-ports=http:80

echo ""
echo "Instance Templates et Groups créés avec succès !"
echo ""
echo "=== Résumé ==="
echo "Templates : web-template, api-template"
echo "Instance Groups : ig-web (2 instances), ig-api (2 instances)"
echo ""
echo "Attendez quelques minutes que les instances démarrent..."
