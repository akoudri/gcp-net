#!/bin/bash
# Lab 2.4 - Exercice 2.4.2 : Créer la VM multi-NIC (appliance)
# Objectif : Déployer une VM avec deux interfaces réseau

set -e

echo "=== Lab 2.4 - Exercice 2 : Créer la VM multi-NIC ==="
echo ""

export ZONE="europe-west1-b"

# La VM multi-NIC doit être créée avec toutes ses interfaces dès le départ
echo "Création de l'appliance avec deux interfaces réseau..."
gcloud compute instances create appliance-vm \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network=vpc-a,subnet=subnet-a,private-network-ip=10.1.0.5,no-address \
    --network-interface=network=vpc-b,subnet=subnet-b,private-network-ip=10.2.0.5,no-address \
    --can-ip-forward \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        # Activer le forwarding IP
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

        # Installer les outils réseau
        apt-get update
        apt-get install -y iptables tcpdump net-tools'

echo ""
echo "VM multi-NIC créée avec succès !"
echo ""

# Vérifier la configuration réseau
echo "=== Configuration réseau de l'appliance ==="
gcloud compute instances describe appliance-vm \
    --zone=$ZONE \
    --format="yaml(networkInterfaces)"

echo ""
echo "Questions à considérer :"
echo "1. Que fait l'option --can-ip-forward ?"
echo "   → Permet à la VM de router du trafic entre ses interfaces"
echo ""
echo "2. Pourquoi les deux sous-réseaux doivent-ils être dans la même région ?"
echo "   → Contrainte GCP : Une VM ne peut avoir que des NICs dans sa région"
echo ""
echo "3. Peut-on ajouter une interface réseau à une VM existante ?"
echo "   → NON, toutes les interfaces doivent être définies à la création"
