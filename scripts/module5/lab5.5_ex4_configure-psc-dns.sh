#!/bin/bash
# Lab 5.5 - Exercice 5.5.4 : Configurer le DNS pour utiliser l'endpoint PSC
# Objectif : Router les requêtes googleapis.com vers l'endpoint PSC

set -e

echo "=== Lab 5.5 - Exercice 4 : Configurer le DNS pour PSC ==="
echo ""

export VPC_NAME="vpc-private-access"

echo "VPC : $VPC_NAME"
echo ""

# Si la zone googleapis-private existe déjà, la supprimer d'abord
echo "Suppression de l'ancienne zone DNS (si elle existe)..."
gcloud dns managed-zones delete googleapis-private --quiet 2>/dev/null || echo "Aucune zone à supprimer"

echo ""

# Créer la nouvelle zone pour PSC
echo "Création de la zone DNS pour PSC..."
gcloud dns managed-zones create googleapis-psc \
    --dns-name="googleapis.com." \
    --visibility=private \
    --networks=$VPC_NAME \
    --description="Zone DNS pour PSC APIs Google"

echo ""
echo "Zone DNS créée !"
echo ""

# Enregistrement A pour l'endpoint PSC - APIs courantes
echo "Création des enregistrements DNS pour les APIs Google..."

echo "- storage.googleapis.com"
gcloud dns record-sets create "storage.googleapis.com." \
    --zone=googleapis-psc \
    --type=A \
    --ttl=300 \
    --rrdatas="10.1.0.100"

# Enregistrement pour d'autres APIs courantes
for API in www.googleapis.com bigquery.googleapis.com pubsub.googleapis.com; do
    echo "- $API"
    gcloud dns record-sets create "${API}." \
        --zone=googleapis-psc \
        --type=A \
        --ttl=300 \
        --rrdatas="10.1.0.100"
done

echo ""
echo "Enregistrements DNS créés !"
echo ""

# Lister les enregistrements
echo "=== Enregistrements DNS dans la zone ==="
gcloud dns record-sets list --zone=googleapis-psc

echo ""
echo "=== DNS configuré pour PSC ! ==="
echo ""
echo "Configuration :"
echo "- storage.googleapis.com → 10.1.0.100"
echo "- www.googleapis.com → 10.1.0.100"
echo "- bigquery.googleapis.com → 10.1.0.100"
echo "- pubsub.googleapis.com → 10.1.0.100"
echo ""
echo "Toutes ces APIs se résoudront vers l'endpoint PSC dans votre VPC."
