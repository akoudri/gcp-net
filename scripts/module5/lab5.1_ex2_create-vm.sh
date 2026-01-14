#!/bin/bash
# Lab 5.1 - Exercice 5.1.2 : Créer une VM sans IP externe
# Objectif : Déployer une VM sans IP publique pour tester PGA

set -e

echo "=== Lab 5.1 - Exercice 2 : Créer une VM sans IP externe ==="
echo ""

# Variables
export VPC_NAME="vpc-private-access"
export REGION="europe-west1"
export ZONE="${REGION}-b"

echo "Zone : $ZONE"
echo ""

# VM sans IP externe avec scopes pour Cloud Storage
echo "Création de la VM sans IP externe..."
gcloud compute instances create vm-pga \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --network=$VPC_NAME \
    --subnet=subnet-pga \
    --no-address \
    --scopes=storage-ro,logging-write \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
        apt-get update && apt-get install -y curl dnsutils'

echo ""
echo "VM créée avec succès !"
echo ""

# Vérifier que la VM n'a pas d'IP externe
echo "=== Vérification de l'IP externe ==="
EXTERNAL_IP=$(gcloud compute instances describe vm-pga \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs)")

if [ -z "$EXTERNAL_IP" ]; then
    echo "✓ Aucune IP externe configurée (comme attendu)"
else
    echo "⚠ IP externe trouvée: $EXTERNAL_IP"
fi

echo ""
echo "=== VM créée avec succès ! ==="
echo ""
echo "Nom: vm-pga"
echo "IP externe: Aucune"
echo "Scopes: storage-ro, logging-write"
echo ""
echo "Astuce: Connectez-vous avec:"
echo "gcloud compute ssh vm-pga --zone=$ZONE --tunnel-through-iap"
