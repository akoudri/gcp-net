#!/bin/bash
# Lab 6.4 - Exercice 6.4.3 : Créer un serveur DNS simulé (dnsmasq)
# Objectif : Déployer un serveur DNS on-premise simulé

set -e

echo "=== Lab 6.4 - Exercice 3 : Créer un serveur DNS simulé ==="
echo ""

# Variables
export VPC_NAME="vpc-dns-lab"
export ZONE="europe-west1-b"

echo "VPC : $VPC_NAME"
echo "Zone : $ZONE"
echo ""

# VM serveur DNS avec dnsmasq
echo "Création du serveur DNS avec dnsmasq..."
gcloud compute instances create dns-server \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network=$VPC_NAME \
    --subnet=subnet-onprem \
    --private-network-ip=10.0.1.53 \
    --no-address \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
# Installer dnsmasq
apt-get update && apt-get install -y dnsmasq dnsutils

# Configurer dnsmasq
cat > /etc/dnsmasq.conf << EOF
# Écouter sur toutes les interfaces
listen-address=0.0.0.0
bind-interfaces

# Ne pas utiliser /etc/resolv.conf
no-resolv

# Serveur DNS upstream (Google DNS)
server=8.8.8.8

# Enregistrements locaux pour corp.local
address=/server.corp.local/10.0.1.100
address=/db.corp.local/10.0.1.101
address=/app.corp.local/10.0.1.102
address=/mail.corp.local/10.0.1.103

# Log des requêtes
log-queries

# Fichier de log
log-facility=/var/log/dnsmasq.log
EOF

# Redémarrer dnsmasq
systemctl restart dnsmasq
systemctl enable dnsmasq

echo "DNS Server configuré!"'
echo ""

# Attendre que le serveur démarre
echo "Attente de 30 secondes pour que le serveur démarre..."
sleep 30
echo ""

echo "Serveur DNS créé avec succès !"
echo ""

echo "=== Vérification ==="
gcloud compute instances describe dns-server --zone=$ZONE \
    --format="get(name,networkInterfaces[0].networkIP,status)"
