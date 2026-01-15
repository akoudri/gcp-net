#!/bin/bash
# Lab 11.6 - Exercice 11.6.2 : Créer l'instance collecteur
# Objectif : Créer la VM collecteur et le groupe d'instances

set -e

echo "=== Lab 11.6 - Exercice 2 : Créer l'instance collecteur ==="
echo ""

# Variables
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Zone : $ZONE"
echo ""

# VM collecteur avec tcpdump préinstallé
echo "Création de la VM collecteur..."
gcloud compute instances create vm-collector \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network=vpc-observability \
    --subnet=subnet-collector \
    --tags=collector \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y tcpdump tshark
# Le trafic arrive encapsulé en VXLAN sur le port 4789
' 2>/dev/null || echo "VM vm-collector existe déjà"

echo ""
echo "VM collecteur créée !"
echo ""

# Règle de pare-feu pour le collecteur
echo "Création de la règle de pare-feu pour le trafic mirroré..."
gcloud compute firewall-rules create vpc-obs-allow-mirroring \
    --network=vpc-observability \
    --action=ALLOW \
    --direction=INGRESS \
    --rules=udp:4789 \
    --source-ranges=10.0.0.0/8 \
    --target-tags=collector 2>/dev/null || echo "Règle vpc-obs-allow-mirroring existe déjà"

echo ""
echo "Règle de pare-feu créée !"
echo ""

# Créer un Instance Group pour le collecteur
echo "Création du groupe d'instances..."
gcloud compute instance-groups unmanaged create ig-collector \
    --zone=$ZONE 2>/dev/null || echo "Groupe ig-collector existe déjà"

gcloud compute instance-groups unmanaged add-instances ig-collector \
    --zone=$ZONE \
    --instances=vm-collector 2>&1 | grep -v "already a member" || true

echo ""
echo "Groupe d'instances créé avec succès !"
echo ""
echo "L'instance collecteur est prête à recevoir le trafic mirroré."
