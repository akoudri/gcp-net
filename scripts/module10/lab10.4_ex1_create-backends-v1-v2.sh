#!/bin/bash
# Lab 10.4 - Exercice 10.4.1 : Créer les backends v1 et v2
# Objectif : Créer deux versions de backends pour le déploiement Canary

set -e

echo "=== Lab 10.4 - Exercice 1 : Créer les backends v1 et v2 ==="
echo ""

# Variables
export REGION="europe-west1"
export ZONE="${REGION}-b"

# Template v1 (stable)
echo "Création du template web-template-v1..."
gcloud compute instance-templates create web-template-v1 \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --region=$REGION \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>App v1</title>
<style>body{background-color:#e8f5e9;font-family:Arial;text-align:center;padding-top:50px;}</style>
</head>
<body>
<h1 style="color:#2e7d32;">Version 1 (Stable)</h1>
<p>Hostname: $(hostname)</p>
</body>
</html>
EOF
echo "OK" > /var/www/html/health
systemctl restart nginx'

echo ""
echo "Création du template web-template-v2..."

# Template v2 (canary)
gcloud compute instance-templates create web-template-v2 \
    --machine-type=e2-small \
    --network=vpc-lb-lab \
    --subnet=subnet-web \
    --region=$REGION \
    --tags=web-server \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head><title>App v2</title>
<style>body{background-color:#e3f2fd;font-family:Arial;text-align:center;padding-top:50px;}</style>
</head>
<body>
<h1 style="color:#1565c0;">Version 2 (Canary)</h1>
<p>Hostname: $(hostname)</p>
</body>
</html>
EOF
echo "OK" > /var/www/html/health
systemctl restart nginx'

echo ""
echo "Création des Instance Groups..."

# Instance groups
gcloud compute instance-groups managed create ig-v1 \
    --template=web-template-v1 \
    --size=2 \
    --zone=$ZONE

gcloud compute instance-groups managed create ig-v2 \
    --template=web-template-v2 \
    --size=1 \
    --zone=$ZONE

echo ""
echo "Configuration des named ports..."

# Named ports
gcloud compute instance-groups managed set-named-ports ig-v1 \
    --zone=$ZONE --named-ports=http:80

gcloud compute instance-groups managed set-named-ports ig-v2 \
    --zone=$ZONE --named-ports=http:80

echo ""
echo "Création des Backend Services..."

# Backend services
gcloud compute backend-services create backend-v1 \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-web \
    --global

gcloud compute backend-services add-backend backend-v1 \
    --instance-group=ig-v1 \
    --instance-group-zone=$ZONE \
    --global

gcloud compute backend-services create backend-v2 \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=hc-web \
    --global

gcloud compute backend-services add-backend backend-v2 \
    --instance-group=ig-v2 \
    --instance-group-zone=$ZONE \
    --global

echo ""
echo "Backends v1 et v2 créés avec succès !"
echo ""
echo "=== Résumé ==="
echo "Version 1 (Stable) :"
echo "  - Template : web-template-v1"
echo "  - Instance Group : ig-v1 (2 instances)"
echo "  - Backend Service : backend-v1"
echo ""
echo "Version 2 (Canary) :"
echo "  - Template : web-template-v2"
echo "  - Instance Group : ig-v2 (1 instance)"
echo "  - Backend Service : backend-v2"
