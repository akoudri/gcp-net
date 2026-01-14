#!/bin/bash
# Lab 6.6 - Exercice 6.6.2 : Créer la zone DNS dans le Hub
# Objectif : Créer une zone DNS privée pour services partagés

set -e

echo "=== Lab 6.6 - Exercice 2 : Créer la zone DNS dans le Hub ==="
echo ""

# Zone DNS privée dans le VPC Hub
echo "Création de la zone DNS services.internal dans le Hub..."
gcloud dns managed-zones create zone-services \
    --dns-name="services.internal." \
    --description="Zone DNS pour services partagés" \
    --visibility=private \
    --networks=vpc-hub
echo ""

# Ajouter des enregistrements
echo "Ajout des enregistrements DNS..."

gcloud dns record-sets create "api.services.internal." \
    --zone=zone-services \
    --type=A \
    --ttl=300 \
    --rrdatas="10.10.0.10"

gcloud dns record-sets create "cache.services.internal." \
    --zone=zone-services \
    --type=A \
    --ttl=300 \
    --rrdatas="10.10.0.20"

gcloud dns record-sets create "monitoring.services.internal." \
    --zone=zone-services \
    --type=A \
    --ttl=300 \
    --rrdatas="10.10.0.30"
echo ""

echo "Zone DNS Hub créée avec succès !"
echo ""

echo "=== Liste des enregistrements ==="
gcloud dns record-sets list --zone=zone-services
