#!/bin/bash
# Lab 10.11 - Exercice 10.11.4 : Tester les Signed URLs
# Objectif : Générer et tester une URL signée

set -e

echo "=== Lab 10.11 - Exercice 4 : Tester les Signed URLs ==="
echo ""

# Vérifier que le script et la clé existent
if [ ! -f "generate_signed_url.py" ]; then
    echo "Erreur : generate_signed_url.py n'existe pas"
    echo "Exécutez d'abord lab10.11_ex3_create-signed-url-script.sh"
    exit 1
fi

if [ ! -f "cdn-signing-key.txt" ]; then
    echo "Erreur : cdn-signing-key.txt n'existe pas"
    echo "Exécutez d'abord lab10.11_ex2_create-signing-key.sh"
    exit 1
fi

# Récupérer l'IP du Load Balancer
LB_IP=$(gcloud compute addresses describe lb-ip-global --global --format="get(address)")
echo "IP du Load Balancer : $LB_IP"
echo ""

# Générer une Signed URL
echo "Génération d'une Signed URL (valide 300 secondes)..."
python3 generate_signed_url.py \
    --url="http://$LB_IP/static/style.css" \
    --key-name=key-v1 \
    --key-file=cdn-signing-key.txt \
    --expires-in=300

echo ""
echo ""
echo "=== Test de l'URL signée ==="
echo ""
echo "Copiez l'URL générée ci-dessus et testez-la dans votre navigateur"
echo "ou avec curl."
echo ""
echo "Note : Par défaut, les signed URLs sont optionnelles."
echo "       Les URLs non signées fonctionnent toujours."
echo ""
echo "Pour forcer l'utilisation de signed URLs uniquement,"
echo "configurez une politique plus stricte dans Cloud CDN."
