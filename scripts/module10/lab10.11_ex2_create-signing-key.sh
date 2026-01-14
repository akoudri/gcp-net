#!/bin/bash
# Lab 10.11 - Exercice 10.11.2 : Créer une clé de signature
# Objectif : Créer une clé pour signer les URLs Cloud CDN

set -e

echo "=== Lab 10.11 - Exercice 2 : Créer une clé de signature ==="
echo ""

# Générer une clé aléatoire (128 bits = 16 bytes)
echo "Génération d'une clé de signature aléatoire..."
head -c 16 /dev/urandom | base64 | tr '+/' '-_' > cdn-signing-key.txt

echo "Clé générée :"
cat cdn-signing-key.txt

echo ""
echo "Ajout de la clé au backend service..."

# Ajouter la clé au backend service
gcloud compute backend-services add-signed-url-key backend-web \
    --key-name=key-v1 \
    --key-file=cdn-signing-key.txt \
    --global

echo ""
echo "Vérification de la configuration..."

# Vérifier
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(cdnPolicy.signedUrlKeyNames)"

echo ""
echo "Configuration du cache max age pour les signed URLs..."

# Configurer le cache max age pour les signed URLs
gcloud compute backend-services update backend-web \
    --signed-url-cache-max-age=3600 \
    --global

echo ""
echo "Clé de signature créée avec succès !"
echo ""
echo "=== Résumé ==="
echo "Nom de la clé : key-v1"
echo "Fichier : cdn-signing-key.txt"
echo "Cache Max Age : 3600s (1 heure)"
echo ""
echo "⚠️  Sécurité :"
echo "  - Gardez cette clé secrète !"
echo "  - Ne la committez pas dans Git"
echo "  - Rotez-la régulièrement"
echo ""
echo "La clé est sauvegardée dans : $(pwd)/cdn-signing-key.txt"
