#!/bin/bash
# Lab 10.11 - Exercice 10.11.5 : Rotation des clés
# Objectif : Effectuer une rotation des clés de signature

set -e

echo "=== Lab 10.11 - Exercice 5 : Rotation des clés ==="
echo ""
echo "Bonne pratique : Rotation régulière des clés de signature"
echo ""

# Générer une nouvelle clé
echo "Génération d'une nouvelle clé (key-v2)..."
head -c 16 /dev/urandom | base64 | tr '+/' '-_' > cdn-signing-key-v2.txt

echo "Nouvelle clé générée :"
cat cdn-signing-key-v2.txt

echo ""
echo "Ajout de la nouvelle clé (sans supprimer l'ancienne)..."

# Ajouter la nouvelle clé (sans supprimer l'ancienne)
gcloud compute backend-services add-signed-url-key backend-web \
    --key-name=key-v2 \
    --key-file=cdn-signing-key-v2.txt \
    --global

echo ""
echo "Vérification des clés actives..."
gcloud compute backend-services describe backend-web \
    --global \
    --format="yaml(cdnPolicy.signedUrlKeyNames)"

echo ""
echo "Nouvelle clé ajoutée avec succès !"
echo ""
echo "=== Processus de rotation ==="
echo "1. ✓ Nouvelle clé créée (key-v2)"
echo "2. ✓ Nouvelle clé ajoutée (l'ancienne reste active)"
echo "3. TODO : Mettre à jour l'application pour utiliser key-v2"
echo "4. TODO : Attendre que toutes les URLs avec key-v1 expirent"
echo "5. TODO : Supprimer l'ancienne clé key-v1"
echo ""
echo "Pour supprimer l'ancienne clé (après migration) :"
echo "  gcloud compute backend-services delete-signed-url-key backend-web \\"
echo "    --key-name=key-v1 --global"
echo ""
echo "Clés sauvegardées dans :"
echo "  - cdn-signing-key.txt (key-v1)"
echo "  - cdn-signing-key-v2.txt (key-v2)"
