#!/bin/bash
# Lab 7.4 - Exercice 7.4.5 : Restaurer le tunnel
# Objectif : Restaurer le tunnel supprimé

set -e

echo "=== Lab 7.4 - Exercice 5 : Restaurer le tunnel ==="
echo ""

export REGION="europe-west1"

echo "Région : $REGION"
echo ""

echo "⚠️  ATTENTION : Ce script nécessite le secret original du tunnel 0."
echo "Si vous ne l'avez pas sauvegardé, vous devrez générer un nouveau secret."
echo ""
read -p "Avez-vous le secret original ? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Génération d'un nouveau secret..."
    SECRET_0=$(openssl rand -base64 24)
    echo "Nouveau secret généré : $SECRET_0"
else
    read -p "Entrez le secret original : " SECRET_0
fi

echo ""

# Recréer le tunnel supprimé
echo ">>> Recréation du tunnel 0..."
gcloud compute vpn-tunnels create tunnel-gcp-to-onprem-0 \
    --vpn-gateway=vpn-gw-gcp \
    --vpn-gateway-region=$REGION \
    --peer-gcp-gateway=vpn-gw-onprem \
    --peer-gcp-gateway-region=$REGION \
    --interface=0 \
    --ike-version=2 \
    --shared-secret="$SECRET_0" \
    --router=router-gcp \
    --router-region=$REGION

echo ""
echo ">>> Attente de la convergence (60 secondes)..."
sleep 60

echo ""

# Vérifier que les deux tunnels sont de nouveau actifs
echo "=== État des tunnels après restauration ==="
gcloud compute vpn-tunnels list --filter="region:$REGION"

echo ""
echo "=== Sessions BGP après restauration ==="
gcloud compute routers get-status router-gcp --region=$REGION \
    --format="table(result.bgpPeerStatus[].name,result.bgpPeerStatus[].status)"

echo ""
echo "=== Restauration terminée ==="
echo ""
echo "NOTE : Si vous avez généré un nouveau secret, vous devrez également"
echo "recréer le tunnel correspondant côté on-premise avec le même secret."
