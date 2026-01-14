#!/bin/bash
# Lab 10.6 - Exercice 10.6.3 : Créer les backends internes
# Objectif : Créer les templates et instance groups pour les microservices internes

set -e

echo "=== Lab 10.6 - Exercice 3 : Créer les backends internes ==="
echo ""

# Variables
export ZONE="europe-west1-b"

# Template pour les microservices
for SERVICE in users orders default; do
    echo "Création du template ${SERVICE}-template..."
    gcloud compute instance-templates create ${SERVICE}-template \
        --machine-type=e2-micro \
        --network=vpc-lb-lab \
        --subnet=subnet-internal \
        --no-address \
        --tags=internal-service \
        --image-family=debian-11 \
        --image-project=debian-cloud \
        --metadata=startup-script="#!/bin/bash
apt-get update && apt-get install -y nginx
cat > /var/www/html/index.html << EOF
{\"service\": \"${SERVICE}\", \"hostname\": \"\$(hostname)\"}
EOF
mkdir -p /var/www/html/${SERVICE}
echo '{\"data\": \"${SERVICE} response\"}' > /var/www/html/${SERVICE}/index.html
echo 'OK' > /var/www/html/health
systemctl restart nginx"

    echo ""
    echo "Création de l'instance group ig-${SERVICE}..."
    gcloud compute instance-groups managed create ig-${SERVICE} \
        --template=${SERVICE}-template \
        --size=1 \
        --zone=$ZONE

    echo ""
    echo "Configuration des named ports..."
    gcloud compute instance-groups managed set-named-ports ig-${SERVICE} \
        --zone=$ZONE \
        --named-ports=http:80

    echo ""
done

echo "Création de la règle de pare-feu pour le trafic interne..."

# Règle de pare-feu pour le trafic interne
gcloud compute firewall-rules create vpc-lb-lab-allow-internal-lb \
    --network=vpc-lb-lab \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=tcp:80 \
    --source-ranges=10.0.0.0/8 \
    --target-tags=internal-service

echo ""
echo "Backends internes créés avec succès !"
echo ""
echo "=== Résumé ==="
echo "Microservices créés :"
echo "  - users (ig-users, users-template)"
echo "  - orders (ig-orders, orders-template)"
echo "  - default (ig-default, default-template)"
echo ""
echo "Configuration :"
echo "  - Machine type : e2-micro"
echo "  - Pas d'IP externe (--no-address)"
echo "  - Subnet : subnet-internal"
echo "  - Tags : internal-service"
