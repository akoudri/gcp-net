#!/bin/bash
# Lab 8.7 - Exercice 8.7.3 : Tester la connexion SSH via IAP
# Objectif : Se connecter à une VM sans IP publique via IAP

set -e

echo "=== Lab 8.7 - Exercice 3 : Tester SSH via IAP ==="
echo ""

export ZONE="europe-west1-b"

echo "Zone : $ZONE"
echo ""

# Vérifier si vm-api-sa existe
if ! gcloud compute instances describe vm-api-sa --zone=$ZONE &>/dev/null; then
    echo "ERREUR : vm-api-sa n'existe pas."
    echo "Créez-la avec : ./lab8.3_ex4_create-vms-with-sa.sh"
    exit 1
fi

# Vérifier que la VM n'a pas d'IP publique
echo ">>> Vérification de l'absence d'IP publique sur vm-api-sa..."
VM_EXTERNAL_IP=$(gcloud compute instances describe vm-api-sa --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)" 2>/dev/null || echo "")

if [ -z "$VM_EXTERNAL_IP" ]; then
    echo "✓ vm-api-sa n'a pas d'IP publique (comme attendu)"
else
    echo "⚠ vm-api-sa a une IP publique : $VM_EXTERNAL_IP"
fi

echo ""
echo ">>> Connexion SSH via IAP à vm-api-sa..."
echo ""
echo "Vous allez vous connecter à vm-api-sa via IAP."
echo "IAP va créer un tunnel sécurisé HTTPS."
echo ""

# Connexion SSH via IAP
gcloud compute ssh vm-api-sa --zone=$ZONE --tunnel-through-iap --command="
echo '=== Connexion SSH via IAP réussie ==='
echo ''
echo 'Hostname:'
hostname
echo ''
echo 'IP interne:'
hostname -I
echo ''
echo 'Vérification absence IP publique:'
curl -s -m 5 http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/ \
    -H 'Metadata-Flavor: Google' 2>&1 || echo 'Aucune IP publique (attendu)'
echo ''
echo 'Test de connectivité Internet via Cloud NAT:'
curl -s -m 5 http://icanhazip.com 2>&1 || echo 'Pas de connectivité Internet directe'
echo ''
echo '=== Déconnexion ==='
"

echo ""
echo "Connexion terminée avec succès !"
echo ""

echo "=== Avantages de IAP ==="
echo ""
echo "✓ Pas besoin de bastion"
echo "✓ Pas d'IP publique sur les VMs"
echo "✓ Authentification Google (MFA, etc.)"
echo "✓ Audit trail complet dans Cloud Logging"
echo "✓ Contrôle d'accès granulaire via IAM"
echo ""

echo "Questions à considérer :"
echo "1. Comment IAP se compare-t-il à un VPN traditionnel ?"
echo "2. Quels sont les cas d'usage où IAP n'est pas approprié ?"
echo "3. Comment monitorer l'utilisation de IAP ?"
