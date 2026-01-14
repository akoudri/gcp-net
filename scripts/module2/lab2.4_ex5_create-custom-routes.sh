#!/bin/bash
# Lab 2.4 - Exercice 2.4.5 : Créer des routes personnalisées
# Objectif : Router le trafic entre VPCs via l'appliance

set -e

echo "=== Lab 2.4 - Exercice 5 : Créer des routes personnalisées ==="
echo ""

export ZONE="europe-west1-b"

# Route dans VPC-A pour atteindre VPC-B via l'appliance
echo "Création de la route VPC-A → VPC-B..."
gcloud compute routes create route-a-to-b \
    --network=vpc-a \
    --destination-range=10.2.0.0/24 \
    --next-hop-instance=appliance-vm \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

echo ""

# Route dans VPC-B pour atteindre VPC-A via l'appliance
echo "Création de la route VPC-B → VPC-A..."
gcloud compute routes create route-b-to-a \
    --network=vpc-b \
    --destination-range=10.1.0.0/24 \
    --next-hop-instance=appliance-vm \
    --next-hop-instance-zone=$ZONE \
    --priority=1000

echo ""
echo "Routes personnalisées créées avec succès !"
echo ""

# Vérifier les routes
echo "=== Routes créées ==="
gcloud compute routes list --filter="network:vpc-a OR network:vpc-b"
echo ""

echo "Les routes sont maintenant configurées pour router le trafic via l'appliance."
echo "Utilisez le script de test pour vérifier la connectivité."
